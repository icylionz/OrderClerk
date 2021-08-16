part of 'categories_table_bloc.dart';

abstract class CategoriesTableState {
  @override
  List<Object> get props => [];
}

class CategoriesTableInitial extends CategoriesTableState {}

class CategoriesTableLoading extends CategoriesTableState {}

class CategoriesTableLoaded extends CategoriesTableState {
  final List<Category?> categories;
  CategoriesTableLoaded({required this.categories});
}

class CategoriesTableError extends CategoriesTableState {
  final error;
  CategoriesTableError({required this.error});
}
