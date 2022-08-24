import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'Building.dart';
import 'Containment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String containmentTable = 'containment';
  String buildingTable = 'building';
  String colId = 'id';
  String colEmail = 'email';
  String colLat = 'lat';
  String colLon = 'lon';
  String colGeom = 'geom';

  Future<Database> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'geometry.db';
    final geomDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return geomDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $containmentTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colLat TEXT,$colLon TEXT,$colEmail TEXT)');
    await db.execute(
        'CREATE TABLE $buildingTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colGeom TEXT,$colEmail TEXT)');
  }

  Future<List<Map<String, dynamic>>> getContainmentMapList(String email) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db
        .query(containmentTable, where: 'email = ?', whereArgs: [email]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getBuildingMapList(String email) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result =
        await db.query(buildingTable, where: 'email = ?', whereArgs: [email]);
    return result;
  }

  Future<List<Containment>> getContainmentList(String email) async {
    final List<Map<String, dynamic>> ContainmentMapList =
        await getContainmentMapList(email);
    final List<Containment> ContainmentList = [];
    ContainmentMapList.forEach((ContainmentMap) {
      ContainmentList.add(Containment.fromMap(ContainmentMap));
    });
    return ContainmentList;
  }

  // Future<List<Building>> getBuildingList(String email) async {
  //   final List<Map<String, dynamic>> BuildingMapList =
  //       await getBuildingMapList(email);
  //   final List<Building> BuildingList = [];
  //   BuildingMapList.forEach((BuildingMap) {
  //     BuildingList.add(Building.fromMap(BuildingMap));
  //   });
  //   return BuildingList;
  // }

  Future<int> insertContainment(Containment containment) async {
    Database db = await this.db;
    final int result = await db.insert(containmentTable, containment.toMap());
    return result;
  }

  Future<int> insertBuilding(Building building) async {
    Database db = await this.db;
    final int result = await db.insert(buildingTable, building.toMap());
    return result;
  }

  Future<int> deleteContainment() async {
    Database db = await this.db;
    final int result = await db.delete(containmentTable, where: null);
    return result;
  }

  Future<int> deleteBuilding() async {
    Database db = await this.db;
    final int result = await db.delete(buildingTable, where: null);
    return result;
  }
}
