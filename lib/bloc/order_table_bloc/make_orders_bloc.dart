import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:OrderClerk/data_sources/distributors_source.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';
part 'make_orders_event.dart';
part 'make_orders_state.dart';

class MakeOrdersBloc extends Bloc<MakeOrderEvents, MakeOrdersState> {
  static List<SelectedItem?> selectedItems = [];
  MakeOrdersBloc() : super(MakeOrdersInitial());

  @override
  Stream<MakeOrdersState> mapEventToState(
    MakeOrderEvents event,
  ) async* {
    if (event is ViewSelected) {
      yield MakeOrdersLoading();
      try {
        //Updates the data sources with the database data

        yield MakeOrdersLoaded(selected: MakeOrdersBloc.selectedItems);
      } catch (e) {
        yield MakeOrdersError(error: e.toString());
      }
    } else if (event is AddSelected) {
      event.items.forEach((item) {
        if (!containsSelected(item, MakeOrdersBloc.selectedItems)) {
          MakeOrdersBloc.selectedItems.add(SelectedItem(item: item));
        } else {}
      });

      yield MakeOrdersLoaded(selected: MakeOrdersBloc.selectedItems);
    } else if (event is ClearSelected) {
      MakeOrdersBloc.selectedItems.clear();
    } else if (event is SubmitSelected) {
      await submitOrder(MakeOrdersBloc.selectedItems);
      MakeOrdersBloc.selectedItems.clear();
    } else if (event is UpdateSelected) {
      MakeOrdersBloc.selectedItems = event.items;
    }
  }
}

//returns true if the element is found in the list
//returns false if the element is not found in list
bool containsSelected(Item element, List<SelectedItem?> list) {
  bool found = false;
  list.forEach((e) {
    if (e!.item == element) {
      found = true;
    }
  });

  return found;
}

//creates an order record in the database with selected items and their quantities
submitOrder(List<SelectedItem?> items) async {
  //fetch the id of the last order to be made
  List<Map<String, dynamic>> lastRecord =
      await DatabaseHelper.instance.getLastRecord("orders");
  int orderID;
  if (lastRecord.length > 0)
    orderID = lastRecord[0]["id"] + 1;
  else
    orderID = 1;
  dynamic db = await DatabaseHelper.instance.database;
  dynamic batch = db.batch();

  DistributorsSource.data.forEach((distro) {
    bool unusedDistro = true;
    List<SelectedItem?> toBeRemoved = [];
    items
        .where((e) => e!.item.distributorID == distro!.id ? true : false)
        .forEach((e) {
      unusedDistro = false;
      // clusters items based on distributor
      int? id = batch.insert("orders", {
        "id": orderID,
        "itemID": e!.item.id,
        "quantity": e.quantity,
        "dateOrdered": DateTime.now().toIso8601String()
      });
      batch.update("items", {"lastOrderMadeID": orderID},
          where: "id = ?", whereArgs: [orderID]);
      toBeRemoved
          .add(e); // removes the item from selected items list when added
    });
    items.removeWhere((element) => toBeRemoved.contains(element));
    if (!unusedDistro) orderID++;
  });

  batch.commit();
}
