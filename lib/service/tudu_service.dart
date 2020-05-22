import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tudu/models/tudu_model.dart';

class TuduService {

  final Future<Database> _database = getDatabasesPath().then((String databasePath) {
    Sqflite.setDebugModeOn(true);

    return openDatabase(
      join(databasePath, 'tudu_database.db'),
      onCreate: (db, version) async => await db.execute("CREATE TABLE tudus(id STRING PRIMARY KEY, text TEXT, creationDate INTEGER, done BOOLEAN)"),
      version: 1);
  });

  Future<void> insertTudu(TuduModel tudu) async {

    final Database db = await _database;

    await db.insert('tudus', tudu.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TuduModel>> getAllTudus() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps = await db.query('tudus');

    return List.generate(maps.length, (i) {
      return TuduModel(
        maps[i]['id'].toString(),
        maps[i]['text'],
        DateTime.fromMillisecondsSinceEpoch(maps[i]['creationDate']),
        maps[i]['done'] == 1,
      );
    });
  }

  Future<void> updateTudu(TuduModel tudu) async {
    final db = await _database;

    await db.update('tudus', tudu.toMap(), where: "id = ?", whereArgs: [tudu.id]);
  }

  Future<void> deleteTudu(TuduModel tudu) async {
  
    final db = await _database;

    await db.delete('tudus', where: "id = ?", whereArgs: [tudu.id]);
  }
}
