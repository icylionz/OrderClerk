import 'package:equatable/equatable.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';

class Distributor with Mappable, EquatableMixin {
  int? id;
  String? name;
  String? address;
  String? email;
  String? telephone;

  Distributor({this.id, this.name, this.address, this.email, this.telephone});

  List<Item?> get items {
    return ItemsSource.data
        .where((element) => element?.distributorID == id)
        .toList();
  }

  static Future<Distributor?> pullDBData({required int id}) async {
    var rec = await DatabaseHelper.instance.query("distributors",
        columns: ["id", "name", "address", "email", "telephone"],
        where: "id = ?",
        whereArgs: [id]);

    if (rec.length > 0) return Mapper.fromJson(rec[0]).toObject<Distributor>();

    return null;
  }

  //copies an object to another object
  copy(Distributor itemSource) {
    this.id = itemSource.id;
    this.name = itemSource.name;
    this.address = itemSource.address;
    this.email = itemSource.email;
    this.telephone = itemSource.telephone;
  }

  @override
  void mapping(Mapper map) {
    map("id", id, (v) => id = v);
    map("name", name, (v) => name = v);
    map("address", address, (v) => address = v);
    map("email", email, (v) => email = v);
    map("telephone", telephone, (v) => telephone = v);
  }

  @override
  List<Object?> get props =>
      [id, name, address, telephone, email, Mappable.factories];
}
