import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/exceptions.dart';
import 'package:OrderClerk/src/queries.dart';

class ItemsSource {
  static List<Item?> data = [];

  /* static Future<List<Item?>> pullData(
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    return await DatabaseHelper.instance
        .query("items", where: where, whereArgs: whereArgs, orderBy: orderBy)
        .then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Item>();
      }).toList();
    });
  } */

  static Future<List<Item?>> pullData(
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    String sql = '''
  SELECT i.*
  FROM items AS i
  LEFT JOIN distributors AS d on i.distributorID = d.id
  LEFT JOIN orders AS o1 on i.lastOrderMadeID = o1.id
  LEFT JOIN orders AS o2 on i.lastOrderReceivedID = o2.id
  LEFT JOIN orders AS o3 on i.lastOrderCancelledID = o3.id
  LEFT JOIN categories AS c on i.categoryID = c.id
  LEFT JOIN formulae AS f on i.formulaID = f.id
  ${(whereArgs != null) ? "WHERE $where " : ""}
  ${(orderBy != null) ? "ORDER BY $orderBy" : ""}


  ''';
    return await DatabaseHelper.instance
        .rawQuery(sql: sql, arguments: whereArgs)
        .then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Item>();
      }).toList();
    });
  }

  static Item extract({required int id}) {
    Item? itemFound;
    for (Item? mem in data) if (mem!.id == id) itemFound = mem;
    if (itemFound != null)
      return itemFound;
    else
      throw new NotFoundException("Item", id);
  }

  static sync() {
    data.forEach((element) {
      if (element!.distributorID != null)
        element.distributor =
            DistributorsSource.extract(id: element.distributorID!);
      if (element.categoryID != null)
        element.category = CategoriesSource.extract(id: element.categoryID!);
      if (element.formulaID != null)
        element.formula = FormulaeSource.extract(id: element.formulaID!);

      List<Order> orders = OrdersSource.extract(itemID: element.id);

      orders.forEach((order) {
        //gets the last order made
        if (element.lastOrderMade == null) {
          element.lastOrderMade = order;
          element.lastOrderMadeID = order.id;
        } else if (element.lastOrderMade!.dateOrdered!
            .isAfter(order.dateOrdered!)) {
          element.lastOrderMade = order;
          element.lastOrderMadeID = order.id;
        }
        //gets the last order received
        if (order.isReceived!) {
          if (element.lastOrderReceived == null) {
            element.lastOrderReceived = order;
            element.lastOrderReceivedID = order.id;
          } else if (element.lastOrderReceived!.dateOrdered!
              .isAfter(order.dateOrdered!)) {
            element.lastOrderReceived = order;
            element.lastOrderReceivedID = order.id;
          }
        }
        //gets the last order cancelled
        if (order.isCancelled!) {
          if (element.lastOrderCancelled == null) {
            element.lastOrderCancelled = order;
            element.lastOrderCancelledID = order.id;
          } else if (element.lastOrderCancelled!.dateOrdered!
              .isAfter(order.dateOrdered!)) {
            element.lastOrderCancelled = order;
            element.lastOrderCancelledID = order.id;
          }
        }
      });
    });
  }
}
