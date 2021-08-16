import 'package:equatable/equatable.dart';
import 'package:expressions/expressions.dart';

import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/src/queries.dart';

class Formula with Mappable, EquatableMixin {
  int id;
  String? expString;
  String? vari;
  var expression;
  Formula({required this.id, required this.expString, required this.vari}) {
    expression = Expression.parse(this.expString!);
  }

  @override
  List<Object?> get props =>
      [id, expString, vari, expression, Mappable.factories];
  double calc(var costPrice) {
    // Create context containing all the variables and functions used in the expression
    var context = {this.vari!: costPrice};

    // Evaluate expression
    final evaluator = const ExpressionEvaluator();
    return evaluator.eval(expression, context);
  }

  static Future<Formula?> pullDBData({required int id}) async {
    //gets the formula from the database based on id from the retrieved item
    var rec = await DatabaseHelper.instance
        .query("formulae", where: "id = ?", whereArgs: [id]);
    return Mapper.fromJson(rec[0]).toObject<Formula>();
  }

  //copies an object to another object
  copy(Formula itemSource) {
    this.id = itemSource.id;
    this.expString = itemSource.expString;
    this.expression = itemSource.expression;
  }

  //maps the attributes to map elements
  void mapping(Mapper map) {
    map("id", id, (v) => id = v);
    map("expString", expString, (v) => expString = v);
    map("vari", vari, (v) => vari = v);
  }
}
