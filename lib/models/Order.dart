import 'package:equatable/equatable.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';

class Order with Mappable, EquatableMixin {
  int? id;
  int? itemID;
  Item? item;
  int? quantity;
  double? unitCost;
  double? totalCost;
  String? batchNumber;
  DateTime? dateOrdered;
  DateTime? dateReceived;
  DateTime? dateCancelled;
  DateTime? dateExpired;
  String? notes;
  bool? isReceived;
  bool? isCancelled;
  bool? isExpired;
  @override
  List<Object?> get props => [
        id,
        itemID,
        item,
        quantity,
        unitCost,
        totalCost,
        batchNumber,
        dateOrdered,
        dateReceived,
        dateCancelled,
        dateExpired,
        notes,
        isReceived,
        isCancelled,
        isExpired,
        Mappable.factories
      ];
  Order(
      {required this.id,
      required this.itemID,
      this.quantity: 0,
      this.dateOrdered,
      this.dateReceived,
      this.dateCancelled,
      this.dateExpired,
      this.batchNumber,
      this.isCancelled = false,
      this.isExpired = false,
      this.isReceived = false,
      this.notes}) {
    this.item = ItemsSource.extract(id: this.itemID!);

    this.totalCost = (this.item!.costPrice ?? 0.0) * (this.quantity ?? 0);
  }
  Order.empty();
  static Future<Order?> pullDBData(
      {required int id, required int itemID}) async {
    var rec = await DatabaseHelper.instance.query("orders",
        where: "id = ? AND itemID = ?", whereArgs: [id, itemID]);
    return Mapper.fromJson(rec[0]).toObject<Order>();
  }

  //copies an object to another object
  copy(Order itemSource) {
    this.id = itemSource.id;
    this.itemID = itemSource.itemID;
    this.quantity = itemSource.quantity;
    this.unitCost = itemSource.unitCost;
    this.totalCost = itemSource.totalCost;
    this.dateCancelled = itemSource.dateCancelled;
    this.dateOrdered = itemSource.dateOrdered;
    this.dateReceived = itemSource.dateReceived;
    this.isReceived = itemSource.isReceived;
    this.isCancelled = itemSource.isCancelled;
    this.dateExpired = itemSource.dateExpired;
    this.batchNumber = itemSource.batchNumber;
    this.isExpired = itemSource.isExpired;
    this.notes = itemSource.notes;
  }

  //maps the attributes to map elements
  @override
  void mapping(Mapper map) {
    map("id", id, (v) => id = v);
    map("itemID", itemID, (v) => itemID = v);
    map("quantity", quantity, (v) => quantity = v);
    map("received", isReceived,
        (v) => v == 1 ? isReceived = true : isReceived = false);
    map("cancelled", isCancelled,
        (v) => v == 1 ? isCancelled = true : isCancelled = false);
    map("expired", isExpired,
        (v) => v == 1 ? isExpired = true : isExpired = false);
    map("dateOrdered", dateOrdered, (v) {
      if (v != null && v != "null") dateOrdered = DateTime.tryParse(v);
    });
    map("dateReceived", dateReceived, (v) {
      if (v != null && v != "null") dateReceived = DateTime.tryParse(v);
    });
    map("dateCancelled", dateCancelled, (v) {
      if (v != null && v != "null") dateCancelled = DateTime.tryParse(v);
    });
    map("dateExpired", dateExpired, (v) {
      if (v != null && v != "null") dateExpired = DateTime.tryParse(v);
    });
    map("batchNumber", batchNumber, (v) => batchNumber = v);
    map("notes", notes, (v) => notes = v);
  }

  void receiveOrder() {
    isReceived = true;
    isCancelled = false;
  }

  void expireItem() {
    isExpired = true;
  }

  void unexpireItem() {
    isExpired = false;
  }

  void cancelOrder() {
    isReceived = false;
    isCancelled = true;
  }

  void unreceiveOrder() {
    isReceived = false;
  }

  void uncancelOrder() {
    isCancelled = false;
  }
}
