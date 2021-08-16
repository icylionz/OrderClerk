part of 'items_table_bloc.dart';

abstract class ItemsTableState {
  @override
  List<Object> get props => [];
}

class ItemsTableInitial extends ItemsTableState {}

class ItemsTableLoading extends ItemsTableState {}

class ItemsTableLoaded extends ItemsTableState {
  final List<Item?> items;
  final List<dynamic> itemColumns;
  ItemsTableLoaded({required this.items, required this.itemColumns});
}

class ItemsTableError extends ItemsTableState {
  final error;
  ItemsTableError({required this.error});
}
