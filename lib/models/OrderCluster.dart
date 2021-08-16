import 'package:equatable/equatable.dart';
import 'package:OrderClerk/models/models.dart';

class OrderCluster with EquatableMixin {
  int id;
  List<Order> orders;

  OrderCluster({required this.id, required this.orders});

  @override
  List<Object?> get props => [id, orders];
}
