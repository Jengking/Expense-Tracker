import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expenses.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'expenses_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  //Begin CRUD Operations
  Future<int> insertExpense(Expenses expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expenses>> getExpenses() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Expenses.fromMap(maps[i]);
    });
  }

  Future<int> updateExpenses(Expenses expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpenses(int id) async {
    Database db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
