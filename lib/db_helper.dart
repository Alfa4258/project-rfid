import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'participants.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE participant (
            bib_number TEXT PRIMARY KEY,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            gender TEXT NOT NULL,
            date_of_birth TEXT NOT NULL,
            address TEXT,
            city TEXT NOT NULL,
            province TEXT NOT NULL,
            country TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            cellphone TEXT NOT NULL,
            category TEXT NOT NULL,
            start_time TEXT,
            finish_time TEXT,
            average_pace TEXT,
            splits TEXT
          )
        ''');
      },
    );
  }

  Future<Map<String, dynamic>?> getParticipant(String bibNumber) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      'participant',
      where: 'bib_number = ?',
      whereArgs: [bibNumber],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllParticipants() async {
    final db = await database;
    return await db.query('participant');
  }

Future<void> updateDatabaseFromExcel(List<Map<String, dynamic>> data) async {
  final db = await DatabaseHelper().database;

  await db.transaction((txn) async {
    for (var row in data) {
      try {
        await txn.insert(
          'participant', // Correct table name
          row,
          conflictAlgorithm: ConflictAlgorithm.replace, // Replace rows with the same primary key
        );
      } catch (e) {
        print('Error inserting row: $row, Error: $e');
      }
    }
  });
}
}