import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
part 'distributors_table_event.dart';
part 'distributors_table_state.dart';

class DistributorsTableBloc
    extends Bloc<DistributorsTableEvents, DistributorsTableState> {
  final DistributorsSource source;
  List<Item?> distributors = [];
  String? where;
  List<dynamic>? whereArgs;
  DistributorsTableBloc({required this.source})
      : super(DistributorsTableInitial());
  setCriteria({String? where, List<dynamic>? whereArgs}) {
    this.where = where;
    this.whereArgs = whereArgs;
  }

  @override
  Stream<DistributorsTableState> mapEventToState(
    DistributorsTableEvents event,
  ) async* {
    if (event is LoadDistributorData) {
      yield DistributorsTableLoading();
      try {
        //Updates the data sources with the database data
        DistributorsSource.data = await DistributorsSource.pullData(
            where: DistributorFilter
                .map["where"], // checks if there is search text
            whereArgs: DistributorFilter
                .map["whereArgs"]); // checks if there is search text

        yield DistributorsTableLoaded(distributors: DistributorsSource.data);
      } catch (e) {
        yield DistributorsTableError(error: e.toString());
      }
    }
  }
}
