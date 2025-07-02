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
        // 각 ALTER TABLE 문을 별도로 실행하고 오류 처리
        try {
          await db.execute('ALTER TABLE todos ADD COLUMN startTime INTEGER;');
        } catch (e) {
          print('startTime 필드 추가 중 오류: $e');
        }

        try {
          await db.execute('ALTER TABLE todos ADD COLUMN endTime INTEGER;');
        } catch (e) {
          print('endTime 필드 추가 중 오류: $e');
        }

        try {
          await db.execute(
            'ALTER TABLE todos ADD COLUMN useTimeProgress INTEGER NOT NULL DEFAULT 0;',
          );
        } catch (e) {
          print('useTimeProgress 필드 추가 중 오류: $e');
        }

        // 기존 데이터 확인
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM todos'),
        );
        print('기존 할 일 데이터 수: $count');
      } catch (e) {
        print('데이터베이스 업그레이드 중 오류 발생: $e');
        // 오류가 발생해도 앱이 계속 실행되도록 함
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
