import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';

class OrdersSource {
  static List<Order?> data = [];
  static Future<List<Order?>> pullData(
      {String? where, List<dynamic>? whereArgs}) async {
    return await DatabaseHelper.instance
        .query("orders", where: where, whereArgs: whereArgs)
        .then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Order>();
      }).toList();
    });
  }

  /* 
    if only itemID is specified then all orders that contain that itemID will be returned
    if only id is specified then all orders that contain that id will be returned
    if both are specified then the orders that matched the parameters will be returned
    
  */
  static List<Order> extract({int? id, int? itemID}) {
    List<Order> ordersFound = [];

    data.forEach((element) {
      if ((itemID != null) && (id != null))
        (element!.id == id) && (element.itemID == itemID)
            ? ordersFound.add(element)
            : null;
      else if (itemID == null) {
        (element!.id == id) ? ordersFound.add(element) : null;
      } else if (id == null) {
        (element!.itemID == itemID) ? ordersFound.add(element) : null;
      }
    });

    return ordersFound;
  }

  static sync() {
    data.forEach((element) {
      if (element!.itemID != null)
        element.item = ItemsSource.extract(id: element.itemID!);
    });
  }

  static List<OrderCluster> get cluster {
    List<OrderCluster> clusters = [];
    data.forEach((element) {
      // if the order's id is present in the list of clusters insert the order into the corresponding cluster

      OrdersSource.idPresent(clusters, element!.id)
          ? clusters
              .where((cluster) => cluster.id == element.id ? true : false)
              .first
              .orders
              .add(element)
          //else create a new cluster with that order's id
          : clusters.add(OrderCluster(id: element.id!, orders: [element]));
    });

    return clusters;
  }

  static bool idPresent(List<OrderCluster> clusters, int? clusterID) {
    bool found = false;
    clusters.forEach((element) {
      if (element.id == clusterID) found = true;
    });

    return found;
  }
}
