import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

  Future<bool> create ( String name, String dob, String gender, String phoneNumber ) async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath,'studentDB.db');
    Database database = await openDatabase(
      singleInstance: true,
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, dob TEXT, gender TEXT, phoneNumber TEXT)'
        );
      }
    );

    int res = await database.insert('students', {'name': name, 'dob': dob, 'gender': gender, 'phoneNumber': phoneNumber},);

    if (res != 0) {
      await database.close();
      return true;
    }
    await database.close();
    return false;
  }

  Future<int> update (int id, {String? name, String? phoneNumber}) async {

    var databasePath = await getDatabasesPath();
    String path = join(databasePath,'studentDB.db');
    Database database = await openDatabase(
        path,
        version: 1,
      singleInstance: true,
    );


      int res = await database.rawUpdate(
        'UPDATE students SET name = "$name", phoneNumber = "$phoneNumber" where id = $id'
      );
      return res;

  }

  Future<int?> delete (int id) async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath,'studentDB.db');
    Database database = await openDatabase(
      path,
      version: 1,
    );

    var res = await database.rawDelete(
      'DELETE FROM students WHERE id = $id'
    );
    await database.close();
    return res;
  }

  Future<List<Map>?> display (String mode, {int? id}) async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath,'studentDB.db');
    Database database = await openDatabase(
      path,
      version: 1,
    );

    if(mode == "all") {
      List<Map>? result = await database.rawQuery(
          'SELECT * FROM students'
      );
      await database.close();
      return result;
    }
    else if (mode == "single") {
      print('ok');
      List<Map>? result = await database.rawQuery(
          'SELECT * FROM students WHERE id = $id'
      );
      await database.close();
      return result;
    }
    await database.close();
    return null;

  }