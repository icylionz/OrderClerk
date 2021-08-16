import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
part 'categories_table_event.dart';
part 'categories_table_state.dart';

class CategoriesTableBloc
    extends Bloc<CategoriesTableEvents, CategoriesTableState> {
  final CategoriesSource source;
  List<Category?> categories = [];
  String? where;
  List<dynamic>? whereArgs;
  CategoriesTableBloc({required this.source}) : super(CategoriesTableInitial());
  setCriteria({String? where, List<dynamic>? whereArgs}) {
    this.where = where;
    this.whereArgs = whereArgs;
  }

  @override
  Stream<CategoriesTableState> mapEventToState(
    CategoriesTableEvents event,
  ) async* {
    if (event is LoadCategoryData) {
      yield CategoriesTableLoading();
      try {
        //Updates the data sources with the database data
        CategoriesSource.data = await CategoriesSource.pullData(
            where:
                CategoryFilter.map["where"], // checks if there is search text
            whereArgs: CategoryFilter
                .map["whereArgs"]); // checks if there is search text

        yield CategoriesTableLoaded(categories: CategoriesSource.data);
      } catch (e) {
        yield CategoriesTableError(error: e.toString());
      }
    }
  }
}
