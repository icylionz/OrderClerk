part of 'distributors_table_bloc.dart';

abstract class DistributorsTableState {
  @override
  List<Object> get props => [];
}

class DistributorsTableInitial extends DistributorsTableState {}

class DistributorsTableLoading extends DistributorsTableState {}

class DistributorsTableLoaded extends DistributorsTableState {
  final List<Distributor?> distributors;
  DistributorsTableLoaded({required this.distributors});
}

class DistributorsTableError extends DistributorsTableState {
  final error;
  DistributorsTableError({required this.error});
}
