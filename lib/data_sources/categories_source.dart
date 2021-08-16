import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/exceptions.dart';
import 'package:OrderClerk/src/queries.dart';

class CategoriesSource {
  static List<Category?> data = [];
  static Future<List<Category?>> pullData(
      {String? where, List<dynamic>? whereArgs}) async {
    return await DatabaseHelper.instance
        .query("categories", where: where, whereArgs: whereArgs)
        .then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Category>();
      }).toList();
    });
  }

  static Category extract({required int id}) {
    Category? itemFound;
    for (Category? mem in data) if (mem!.id == id) itemFound = mem;
    if (itemFound != null)
      return itemFound;
    else
      throw new NotFoundException("Category", id);
  }
}
