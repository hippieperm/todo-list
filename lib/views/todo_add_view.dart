import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/todo_viewmodel.dart';

class TodoAddView extends StatefulWidget {
  const TodoAddView({super.key});

  @override
  State<TodoAddView> createState() => _TodoAddViewState();
}

class _TodoAddViewState extends State<TodoAddView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _priority = 2; // 기본 우선순위: 중간

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
      appBar: AppBar(title: const Text('새 할 일')),
      body: SingleChildScrollView(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              autofocus: true,
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _addTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('추가'),
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

  void _addTodo() {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    // 입력값 검증
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    // 새 할 일 객체 생성
    final newTodo = Todo(
      title: title,
      description: _descriptionController.text.trim(),
      priority: _priority,
    );

    // 저장
    viewModel.addTodo(newTodo);
    Navigator.pop(context);
  }
}
