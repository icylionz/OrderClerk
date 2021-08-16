import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/exceptions.dart';
import 'package:OrderClerk/src/queries.dart';

class DistributorsSource {
  static List<Distributor?> data = [];
  static Future<List<Distributor?>> pullData(
      {String? where, List<dynamic>? whereArgs}) async {
    return await DatabaseHelper.instance
        .query("distributors", where: where, whereArgs: whereArgs)
        .then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Distributor>();
      }).toList();
    });
  }

  static Distributor extract({required int id}) {
    Distributor? itemFound;
    for (Distributor? mem in data) if (mem!.id == id) itemFound = mem;
    if (itemFound != null)
      return itemFound;
    else
      throw new NotFoundException("Distributor", id);
  }
}
