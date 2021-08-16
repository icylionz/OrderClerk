import 'package:equatable/equatable.dart';
import 'package:OrderClerk/models/models.dart';

class SelectedItem with EquatableMixin {
  Item item = Item();
  int quantity = 1;

  SelectedItem({required this.item, this.quantity = 1});

  @override
  List<Object?> get props => [
        item,
        quantity,
      ];
}
