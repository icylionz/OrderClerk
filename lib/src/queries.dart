import 'dart:async';
import 'package:OrderClerk/src/file_handling.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbName = "dBase.db";
  static final _dbVersion = 1;
  static final itemTableSQL = '''
  CREATE TABLE IF NOT EXISTS items(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    distributorID INTEGER NOT NULL,
    packageSize TEXT,
    categoryID INTEGER,
    costPrice FLOAT,
    sellingPrice FLOAT,
    formulaID INTEGER,
    lastOrderMadeID INTEGER,
    lastOrderReceivedID INTEGER,
    lastOrderCancelledID INTEGER,
    toBeOrdered INTEGER DEFAULT 0
  );

  ''';
  static final distributorTableSQL = '''
    CREATE TABLE IF NOT EXISTS distributors(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT,
      email TEXT,
      telephone TEXT
    );  

  ''';
  static final ordersTableSQL = '''
    CREATE TABLE IF NOT EXISTS orders(
      id INT NOT NULL,
      itemID INT NOT NULL,
      quantity INT,
      dateOrdered TEXT,
      dateReceived TEXT,
      dateCancelled TEXT,
      dateExpired TEXT,
      batchNumber TEXT,
      notes TEXT,
      received INTEGER DEFAULT 0,
      expired INTEGER DEFAULT 0,
      cancelled INTEGER DEFAULT 0
    );
  ''';
  static final categoryTableSQL = '''
    CREATE TABLE IF NOT EXISTS categories(
      id INTEGER PRIMARY KEY,
      name TEXT
    );
  ''';
  static final formulaTableSQL = '''
    CREATE TABLE IF NOT EXISTS formulae(
      id INTEGER PRIMARY KEY,
      expString TEXT NOT NULL,
      vari TEXT NOT NULL
    );
  ''';
  //making it a single use class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    String path = join(FileHandler.dir.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database? db, int version) async {
    await db!.execute(itemTableSQL);
    await db.execute(distributorTableSQL);
    await db.execute(ordersTableSQL);
    await db.execute(categoryTableSQL);
    await db.execute(formulaTableSQL);
  }

  Future insert(Map<String, dynamic> row, String tableName) async {
    Database? db = await instance.database;

    return await db?.insert(tableName, row,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future update(Map<String, dynamic> row, String tableName, String? where,
      List<dynamic> whereArgs) async {
    Database? db = await instance.database;

    return await db?.update(tableName, row,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future delete({required String tableName, String? where, whereArgs}) async {
    Database? db = await instance.database;
    await db?.delete(tableName, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<dynamic>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    Database? db = await instance.database;
    return await db!.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
      {required String sql, List<Object?>? arguments}) async {
    Database? db = await instance.database;
    return await db!.rawQuery(sql, arguments);
  }

  Future<List<Map<String, dynamic>>> getLastRecord(table) async {
    Database? db = await instance.database;
    return await db!.rawQuery(
        "SELECT * FROM $table WHERE ROWID = (SELECT MAX(ID)  FROM $table);");
  }
}
