import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
part 'view_orders_event.dart';
part 'view_orders_state.dart';

class ViewOrdersBloc extends Bloc<ViewOrdersEvents, ViewOrdersState> {
  final OrdersSource source;
  List<Item?> orders = [];
  List<dynamic> orderColumns = [];
  String? where;
  List<dynamic>? whereArgs;
  ViewOrdersBloc({required this.source}) : super(ViewOrdersInitial());
  setCriteria({String? where, List<dynamic>? whereArgs}) {
    this.where = where;
    this.whereArgs = whereArgs;
  }

  @override
  Stream<ViewOrdersState> mapEventToState(
    ViewOrdersEvents event,
  ) async* {
    if (event is LoadOrderData) {
      yield ViewOrdersLoading();
      try {
        //Updates the data sources with the database data
        OrdersSource.data = await OrdersSource.pullData(
            where: OrderFilter.map["where"], // checks if there is search text
            whereArgs:
                OrderFilter.map["whereArgs"]); // checks if there is search text
        ItemsSource.data = await ItemsSource.pullData();
        DistributorsSource.data = await DistributorsSource.pullData();
        CategoriesSource.data = await CategoriesSource.pullData();
        FormulaeSource.data = await FormulaeSource.pullData();

        //syncs data from 2 sources
        ItemsSource.sync();
        OrdersSource.sync();
        yield ViewOrdersLoaded(orders: OrdersSource.cluster);
      } catch (e) {
        yield ViewOrdersError(error: e.toString());
      }
    }
  }
}
