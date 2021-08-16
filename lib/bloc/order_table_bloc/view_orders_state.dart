part of 'view_orders_bloc.dart';

abstract class ViewOrdersState {
  @override
  List<Object> get props => [];
}

class ViewOrdersInitial extends ViewOrdersState {}

class ViewOrdersLoading extends ViewOrdersState {}

class ViewOrdersLoaded extends ViewOrdersState {
  final List<OrderCluster?> orders;
  ViewOrdersLoaded({required this.orders});
}

class ViewOrdersError extends ViewOrdersState {
  final error;
  ViewOrdersError({required this.error});
}
