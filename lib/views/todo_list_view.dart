import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/utils/date_formatter.dart';
import 'package:todo/viewmodels/theme_viewmodel.dart';
import 'package:todo/viewmodels/todo_viewmodel.dart';
import 'package:todo/views/todo_detail_view.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.todos.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          itemCount: viewModel.todos.length,
          itemBuilder: (context, index) {
            final todo = viewModel.todos[index];
            return _buildTodoItem(context, todo, viewModel);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text('할 일이 없습니다', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '새로운 할 일을 추가해보세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(
    BuildContext context,
    Todo todo,
    TodoViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;

    // 우선순위에 따른 색상
    Color priorityColor;
    String priorityText;

    switch (todo.priority) {
      case 1:
        priorityColor = isDarkMode ? Colors.green.shade300 : Colors.green;
        priorityText = '낮음';
        break;
      case 3:
        priorityColor = isDarkMode ? Colors.red.shade300 : Colors.red;
        priorityText = '높음';
        break;
      default:
        priorityColor = isDarkMode ? Colors.orange.shade300 : Colors.orange;
        priorityText = '중간';
    }

    // iOS 스타일 스와이프 기능
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: const Color(0xFF34C759), // iOS 녹색
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFFF3B30), // iOS 빨간색
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 왼쪽에서 오른쪽으로 스와이프: 완료/미완료 토글
          viewModel.toggleTodoStatus(todo);
          return false; // 스와이프 후 원래 위치로 돌아가도록
        } else {
          // 오른쪽에서 왼쪽으로 스와이프: 삭제
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('할 일 삭제'),
              content: const Text('이 할 일을 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('삭제', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          viewModel.deleteTodo(todo.id);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: todo.isCompleted
              ? BorderSide.none
              : BorderSide(color: priorityColor, width: 1),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TodoDetailView(todo: todo),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 체크박스
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    shape: const CircleBorder(),
                    value: todo.isCompleted,
                    activeColor: colorScheme.primary,
                    onChanged: (value) {
                      viewModel.toggleTodoStatus(todo);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 할 일 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? colorScheme.onSurface.withOpacity(0.6)
                                    : colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!todo.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                priorityText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (todo.description.isNotEmpty)
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        todo.isCompleted
                            ? '완료: ${DateFormatter.formatDate(todo.completedAt!)}'
                            : '생성: ${DateFormatter.formatDate(todo.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? colorScheme.onSurface.withOpacity(0.7)
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPriorityDialog(
    BuildContext context,
    Todo todo,
    TodoViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('우선순위 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriorityOption(context, '높음', 3, todo, viewModel),
              const SizedBox(height: 8),
              _buildPriorityOption(context, '중간', 2, todo, viewModel),
              const SizedBox(height: 8),
              _buildPriorityOption(context, '낮음', 1, todo, viewModel),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    String label,
    int priority,
    Todo todo,
    TodoViewModel viewModel,
  ) {
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;

    Color color;
    switch (priority) {
      case 1:
        color = isDarkMode ? Colors.green.shade300 : Colors.green;
        break;
      case 3:
        color = isDarkMode ? Colors.red.shade300 : Colors.red;
        break;
      default:
        color = isDarkMode ? Colors.orange.shade300 : Colors.orange;
    }

    return InkWell(
      onTap: () {
        viewModel.updateTodoPriority(todo, priority);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: todo.priority == priority
                ? color
                : Colors.grey.withOpacity(0.3),
            width: todo.priority == priority ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.flag, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: todo.priority == priority
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: todo.priority == priority ? color : null,
              ),
            ),
            const Spacer(),
            if (todo.priority == priority)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
