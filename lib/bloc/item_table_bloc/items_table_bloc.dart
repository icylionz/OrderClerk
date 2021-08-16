import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
part 'items_table_event.dart';
part 'items_table_state.dart';

class ItemsTableBloc extends Bloc<ItemTableEvents, ItemsTableState> {
  final ItemsSource source;
  static bool running = false;
  List<Item?> items = [];
  List<dynamic> itemColumns = [];
  String? where;
  List<dynamic>? whereArgs;
  ItemsTableBloc({required this.source}) : super(ItemsTableInitial());
  setCriteria({String? where, List<dynamic>? whereArgs}) {
    this.where = where;
    this.whereArgs = whereArgs;
  }

  @override
  Stream<ItemsTableState> mapEventToState(
    ItemTableEvents event,
  ) async* {
    if (event is LoadData) {
      yield ItemsTableLoading();
      try {
        itemColumns = ItemFilter.columns; //gets the columns from the filter

        //Updates the data sources with the database data
        ItemsSource.data = await ItemsSource.pullData(
            where: ItemFilter.map["where"],
            whereArgs: ItemFilter.map["whereArgs"],
            orderBy: ItemFilter.orderBy); // checks if there is search text
        DistributorsSource.data = await DistributorsSource.pullData();
        CategoriesSource.data = await CategoriesSource.pullData();
        FormulaeSource.data = await FormulaeSource.pullData();
        OrdersSource.data = await OrdersSource.pullData();

        ItemsSource.sync();

        yield ItemsTableLoaded(
            items: ItemsSource.data, itemColumns: itemColumns);
      } catch (e) {
        yield ItemsTableError(error: e.toString());
      }
    }
  }
}

class UnknownException {
  String message;
  UnknownException(this.message);
}
