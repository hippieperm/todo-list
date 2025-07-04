import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';

class TodoViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  bool _isLoading = false;
  String _filter = 'all'; // 'all', 'completed', 'incomplete'
  String _searchQuery = '';

  List<Todo> get todos => _filteredTodos;
  bool get isLoading => _isLoading;
  String get filter => _filter;
  String get searchQuery => _searchQuery;

  TodoViewModel() {
    loadTodos();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _databaseService.getTodos();
      debugPrint('할 일 ${_todos.length}개 로드됨');

      // 데이터 유효성 검사
      _todos = _todos.where((todo) {
        try {
          // 필수 필드 검증
          if (todo.id.isEmpty || todo.title.isEmpty) {
            debugPrint('유효하지 않은 할 일 데이터 발견: ${todo.id}');
            return false;
          }
          return true;
        } catch (e) {
          debugPrint('할 일 데이터 처리 중 오류: $e');
          return false;
        }
      }).toList();

      _applyFilters();
    } catch (e) {
      debugPrint('할 일 목록 로딩 중 오류 발생: $e');
      _todos = [];
      _filteredTodos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      switch (_filter) {
        case 'completed':
          _filteredTodos = _todos.where((todo) => todo.isCompleted).toList();
          break;
        case 'incomplete':
          _filteredTodos = _todos.where((todo) => !todo.isCompleted).toList();
          break;
        default:
          _filteredTodos = List.from(_todos);
      }
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredTodos = _todos
          .where(
            (todo) =>
                todo.title.toLowerCase().contains(query) ||
                todo.description.toLowerCase().contains(query),
          )
          .toList();

      if (_filter == 'completed') {
        _filteredTodos = _filteredTodos
            .where((todo) => todo.isCompleted)
            .toList();
      } else if (_filter == 'incomplete') {
        _filteredTodos = _filteredTodos
            .where((todo) => !todo.isCompleted)
            .toList();
      }
    }

    // 우선순위에 따라 정렬
    _filteredTodos.sort((a, b) {
      // 우선 미완료된 항목을 완료된 항목보다 위에 표시
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // 그 다음 우선순위로 정렬
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority); // 높은 우선순위가 위로
      }

      // 마지막으로 생성 날짜로 정렬
      return b.createdAt.compareTo(a.createdAt); // 최신 항목이 위로
    });

    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  Future<bool> addTodo(Todo todo) async {
    try {
      debugPrint('할 일 추가 시도: ${todo.title}');
      debugPrint('시간 진행률 사용: ${todo.useTimeProgress}');
      if (todo.useTimeProgress) {
        debugPrint('시작 시간: ${todo.startTime}');
        debugPrint('종료 시간: ${todo.endTime}');
      }

      await _databaseService.insertTodo(todo);
      await loadTodos();
      return true;
    } catch (e) {
      debugPrint('할 일 추가 중 오류 발생: $e');
      return false;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _databaseService.updateTodo(todo);
      await loadTodos();
    } catch (e) {
      debugPrint('할 일 업데이트 중 오류 발생: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _databaseService.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      debugPrint('할 일 삭제 중 오류 발생: $e');
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      completedAt: !todo.isCompleted ? DateTime.now() : null,
    );
    await updateTodo(updatedTodo);
  }

  Future<void> updateTodoPriority(Todo todo, int priority) async {
    final updatedTodo = todo.copyWith(priority: priority);
    await updateTodo(updatedTodo);
  }
}
