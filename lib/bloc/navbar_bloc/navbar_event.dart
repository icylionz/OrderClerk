part of 'navbar_bloc.dart';

abstract class NavbarEvent {
  final name = "nothing";
}

class BlankEvent extends NavbarEvent {
  final name = "blank view";
}

class DefaultEvent extends NavbarEvent {
  final name = "default view";
}

class ViewItemEvent extends NavbarEvent {}

class ViewDistributorEvent extends NavbarEvent {}

class ViewOrderEvent extends NavbarEvent {}
class MakeOrderEvent extends NavbarEvent {}

class ViewCategoryEvent extends NavbarEvent {}
class ViewSettingsEvent extends NavbarEvent {}

class ViewFormulaEvent extends NavbarEvent {}
