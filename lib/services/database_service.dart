import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER,
        priority INTEGER NOT NULL
      )
    ''');
  }

  // Todo 추가
  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Todo 업데이트
  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Todo 삭제
  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // 모든 Todo 가져오기
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // 완료된 Todo 가져오기
  Future<List<Todo>> getCompletedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'isCompleted = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // 미완료된 Todo 가져오기
  Future<List<Todo>> getIncompleteTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'isCompleted = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
}
