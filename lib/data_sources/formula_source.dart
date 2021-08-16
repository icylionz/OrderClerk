import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/exceptions.dart';
import 'package:OrderClerk/src/queries.dart';

class FormulaeSource {
  static List<Formula?> data = [];
  static Future<List<Formula?>> pullData(
      {String? where, List<dynamic>? whereArgs}) async {
    return await DatabaseHelper.instance.query("formulae").then((dbData) {
      return dbData.map((row) {
        return Mapper.fromJson(row).toObject<Formula>();
      }).toList();
    });
  }

  static Formula extract({required int id}) {
    Formula? itemFound;
    for (Formula? mem in data) if (mem!.id == id) itemFound = mem;
    if (itemFound != null)
      return itemFound;
    else
      throw new NotFoundException("Formula", id);
  }
}
