import 'package:equatable/equatable.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/models/Category.dart';
import 'package:OrderClerk/models/Distributor.dart';
import 'package:OrderClerk/models/Formula.dart';
import 'package:OrderClerk/models/Order.dart';
import 'package:OrderClerk/src/queries.dart';

class Item with Mappable, EquatableMixin {
  int? id;
  String? name;
  int? distributorID;
  Distributor? distributor;
  double? costPrice;
  double? sellingPrice;
  String? packageSize;
  int? categoryID;
  Category? category;
  int? formulaID;
  Formula? formula;
  int? lastOrderMadeID;
  Order? lastOrderMade;
  int? lastOrderReceivedID;
  Order? lastOrderReceived;
  int? lastOrderCancelledID;
  Order? lastOrderCancelled;
  bool? toBeOrdered;

  @override
  List<Object?> get props => [
        id,
        name,
        distributor,
        distributorID,
        costPrice,
        sellingPrice,
        packageSize,
        category,
        categoryID,
        formula,
        formulaID,
        lastOrderMade,
        lastOrderMadeID,
        lastOrderCancelled,
        lastOrderCancelledID,
        lastOrderReceived,
        lastOrderReceivedID,
        Mappable.factories
      ];
  //create an object filled with database record files
  Item.pull({
    this.id,
  }) {
    if (this.id != null) pullDBData();
  }

  Item(
      {this.id,
      this.name,
      this.distributorID,
      this.costPrice,
      this.sellingPrice,
      this.packageSize,
      this.categoryID,
      this.formulaID,
      this.lastOrderMadeID,
      this.lastOrderReceivedID,
      this.lastOrderCancelledID,
      this.toBeOrdered: false});
  //copies an object to another object
  copy(Item itemSource) {
    this.category = itemSource.category;
    this.categoryID = itemSource.categoryID;
    this.id = itemSource.id;
    this.name = itemSource.name;
    this.costPrice = itemSource.costPrice;
    this.sellingPrice = itemSource.sellingPrice;
    this.packageSize = itemSource.packageSize;
    this.distributorID = itemSource.distributorID;
    this.distributor = itemSource.distributor;
    this.formulaID = itemSource.formulaID;
    this.formula = itemSource.formula;
    this.lastOrderMadeID = itemSource.lastOrderMadeID;
    this.lastOrderMade = itemSource.lastOrderMade;
    this.lastOrderReceivedID = itemSource.lastOrderReceivedID;
    this.lastOrderReceived = itemSource.lastOrderReceived;
    this.lastOrderCancelledID = itemSource.lastOrderCancelledID;
    this.lastOrderCancelled = itemSource.lastOrderCancelled;
    this.toBeOrdered = itemSource.toBeOrdered;
  }

  //fill object fields with database values
  Future pullDBData() async {
    if (this.id != null && this.id! > 0) {
      List<Map<String, dynamic>> rec = await DatabaseHelper.instance
          .query("items", where: "id = ?", whereArgs: [this.id]);
      Item? retrievedItem = Mapper.fromJson(rec[0]).toObject<Item>();

      if (retrievedItem != null) this.copy(retrievedItem);
    }
  }

  //pulls the objects from the database
  init() async {
    if (this.distributorID != null)
      distributor = await Distributor.pullDBData(id: this.distributorID!);
    if (this.categoryID != null)
      category = await Category.pullDBData(id: this.categoryID!);
    if (formulaID != null) formula = await Formula.pullDBData(id: formulaID!);
    if (lastOrderMadeID != null)
      lastOrderMade = await Order.pullDBData(id: lastOrderMadeID!, itemID: id!);
    if (lastOrderReceivedID != null)
      lastOrderReceived =
          await Order.pullDBData(id: lastOrderReceivedID!, itemID: id!);
    if (lastOrderCancelledID != null)
      lastOrderCancelled =
          await Order.pullDBData(id: lastOrderCancelledID!, itemID: id!);
  }

  //maps the attributes to map elements
  @override
  void mapping(Mapper map) async {
    map("id", id, (v) => id = v);
    map("name", name, (v) => name = v);
    map("distributorID", distributorID, (v) {
      distributorID = v;
    });
    map("costPrice", costPrice, (v) {
      costPrice = v;
    });
    map("sellingPrice", sellingPrice, (v) {
      sellingPrice = v;
    });
    map("packageSize", packageSize, (v) {
      packageSize = v;
    });
    map("categoryID", category, (v) {
      categoryID = v;
    });
    map("formulaID", formula, (v) {
      formulaID = v;
    });
    map("lastOrderMadeID", lastOrderMade, (v) {
      lastOrderMadeID = v;
    });
    map("lastOrderReceivedID", lastOrderReceived, (v) {
      lastOrderReceivedID = v;
    });
    map("lastOrderCancelledID", lastOrderCancelled, (v) {
      lastOrderCancelledID = v;
    });
    map("toBeOrdered", toBeOrdered, (v) {
      toBeOrdered = v == 1 ? true : false;
    });
  }
}
