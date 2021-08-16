import 'package:equatable/equatable.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';

class Category with Mappable, EquatableMixin {
  int? id;
  String? name;

  Category({this.id, this.name});

  List<Item?> get items {
    return ItemsSource.data
        .where((element) => element?.categoryID == id)
        .toList();
  }

  static Future<Category?> pullDBData({required int id}) async {
    var rec = await DatabaseHelper.instance.query("categories",
        columns: ["id", "name"], where: "id = ?", whereArgs: [id]);

    if (rec.length > 0) return Mapper.fromJson(rec[0]).toObject<Category>();

    return null;
  }

  //copies an object to another object
  copy(Category itemSource) {
    this.id = itemSource.id;
    this.name = itemSource.name;
  }

  @override
  void mapping(Mapper map) {
    map("id", id, (v) => id = v);
    map("name", name, (v) => name = v);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        Mappable.factories,
      ];
}
