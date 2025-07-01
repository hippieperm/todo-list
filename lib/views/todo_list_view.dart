import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/todo_model.dart';
import 'package:todo/utils/date_formatter.dart';
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

    // 우선순위에 따른 색상
    Color priorityColor;
    String priorityText;

    switch (todo.priority) {
      case 1:
        priorityColor = Colors.green;
        priorityText = '낮음';
        break;
      case 3:
        priorityColor = Colors.red;
        priorityText = '높음';
        break;
      default:
        priorityColor = Colors.orange;
        priorityText = '중간';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                viewModel.deleteTodo(todo.id);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '삭제',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) {
                _showPriorityDialog(context, todo, viewModel);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.flag,
              label: '우선순위',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
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
                            color: colorScheme.onSurface.withOpacity(0.5),
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
    Color color;
    switch (priority) {
      case 1:
        color = Colors.green;
        break;
      case 3:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
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
