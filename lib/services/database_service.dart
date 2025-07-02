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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
      onConfigure: _configureForeignKey,
    );
  }

  Future<void> _configureForeignKey(Database db) async {
    // 외래키 제약 조건 활성화
    await db.execute('PRAGMA foreign_keys = ON');
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
        priority INTEGER NOT NULL,
        startTime INTEGER,
        endTime INTEGER,
        useTimeProgress INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 버전 1에서 2로 업그레이드: 시간 관련 필드 추가
      try {
        await db.transaction((txn) async {
          // 각 ALTER TABLE 문을 별도로 실행
          await txn.execute('ALTER TABLE todos ADD COLUMN startTime INTEGER;');
          await txn.execute('ALTER TABLE todos ADD COLUMN endTime INTEGER;');
          await txn.execute(
            'ALTER TABLE todos ADD COLUMN useTimeProgress INTEGER NOT NULL DEFAULT 0;',
          );
        });
      } catch (e) {
        print('데이터베이스 업그레이드 오류: $e');

        // 테이블을 다시 생성하는 방법 (기존 데이터는 손실됨)
        // 실제 앱에서는 데이터 마이그레이션 로직이 필요할 수 있음
        await db.execute('DROP TABLE IF EXISTS todos');
        await _createDb(db, newVersion);
      }
    }
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
