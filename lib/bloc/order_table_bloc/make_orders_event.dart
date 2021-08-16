part of 'make_orders_bloc.dart';

abstract class MakeOrderEvents {
  const MakeOrderEvents();

  @override
  List<Object> get props => [];
}

class ViewSelected extends MakeOrderEvents {}

class AddSelected extends MakeOrderEvents {
  final List<Item> items;
  AddSelected({required this.items});
}

class ClearSelected extends MakeOrderEvents {}

class UpdateSelected extends MakeOrderEvents {
  final List<SelectedItem?> items;
  UpdateSelected({required this.items});
}

class SubmitSelected extends MakeOrderEvents {}
