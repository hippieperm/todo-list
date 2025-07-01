import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/utils/date_formatter.dart';
import 'package:todo/viewmodels/theme_viewmodel.dart';
import 'package:todo/viewmodels/todo_viewmodel.dart';

class TodoDetailView extends StatefulWidget {
  final Todo todo;

  const TodoDetailView({super.key, required this.todo});

  @override
  State<TodoDetailView> createState() => _TodoDetailViewState();
}

class _TodoDetailViewState extends State<TodoDetailView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _isCompleted = widget.todo.isCompleted;
    _priority = widget.todo.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 상세'),
        actions: [
          IconButton(
            onPressed: _deleteTodo,
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '할 일 제목을 입력하세요',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 설명 입력
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                  hintText: '할 일에 대한 설명을 입력하세요 (선택사항)',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // 우선순위 선택
              Text('우선순위', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityButton(
                    context,
                    '낮음',
                    1,
                    isDarkMode ? Colors.green.shade300 : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    '중간',
                    2,
                    isDarkMode ? Colors.orange.shade300 : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityButton(
                    context,
                    '높음',
                    3,
                    isDarkMode ? Colors.red.shade300 : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 완료 여부
              Row(
                children: [
                  Checkbox(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('완료됨'),
                ],
              ),
              const SizedBox(height: 16),

              // 날짜 정보
              if (widget.todo.createdAt != null)
                Text(
                  '생성일: ${DateFormatter.formatDate(widget.todo.createdAt)}',
                  style: TextStyle(
                    color: isDarkMode
                        ? colorScheme.onSurface.withOpacity(0.8)
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              if (widget.todo.completedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '완료일: ${DateFormatter.formatDate(widget.todo.completedAt!)}',
                    style: TextStyle(
                      color: isDarkMode
                          ? colorScheme.onSurface.withOpacity(0.8)
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('저장'),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
    BuildContext context,
    String label,
    int priority,
    Color color,
  ) {
    final isSelected = _priority == priority;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTodo() {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    // 입력값 검증
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    // 업데이트된 할 일 객체 생성
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: _isCompleted,
      completedAt: _isCompleted
          ? (widget.todo.completedAt ?? DateTime.now())
          : null,
      priority: _priority,
    );

    // 저장
    viewModel.updateTodo(updatedTodo);
    Navigator.pop(context);
  }

  void _deleteTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: const Text('이 할 일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final viewModel = Provider.of<TodoViewModel>(
                context,
                listen: false,
              );
              viewModel.deleteTodo(widget.todo.id);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 상세 화면 닫기
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
