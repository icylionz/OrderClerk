part of 'make_orders_bloc.dart';

abstract class MakeOrdersState {
  @override
  List<Object> get props => [];
}

class MakeOrdersInitial extends MakeOrdersState {}

class MakeOrdersAdded extends MakeOrdersState {}

class MakeOrdersLoading extends MakeOrdersState {}

class MakeOrdersLoaded extends MakeOrdersState {
  final List<SelectedItem?> selected;
  MakeOrdersLoaded({required this.selected});
  //returns the totalCost of the selected items
  double get totalCost {
    double totalCost = 0.0;
    selected.forEach((element) {
      totalCost += (element!.item.costPrice ?? 0.0) * element.quantity;
    });
    return totalCost;
  }
}

class MakeOrdersSubmitted extends MakeOrdersState {}

class MakeOrdersError extends MakeOrdersState {
  final error;
  MakeOrdersError({required this.error});
}
