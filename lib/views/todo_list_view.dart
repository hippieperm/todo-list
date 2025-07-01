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
          return await _showDeleteConfirmDialog(context, todo);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          viewModel.deleteTodo(todo.id);

          // 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('할 일이 삭제되었습니다'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: '실행 취소',
                onPressed: () {
                  // 실행 취소 로직 (실제로는 구현해야 함)
                },
              ),
            ),
          );
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

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, Todo todo) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '할 일 삭제 다이얼로그',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 8,
              icon: ShakeAnimatedIcon(
                icon: Icons.delete_forever_rounded,
                color: Colors.red,
                size: 36,
              ),
              title: const Text(
                '할 일 삭제',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '정말로 이 할 일을 삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${todo.title}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                _buildDialogButton(
                  context: context,
                  label: '취소',
                  onPressed: () => Navigator.pop(context, false),
                  isPrimary: false,
                ),
                const SizedBox(width: 12),
                _buildDialogButton(
                  context: context,
                  label: '삭제',
                  onPressed: () => Navigator.pop(context, true),
                  isPrimary: true,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (isDestructive ? Colors.red : colorScheme.primary)
              : colorScheme.surfaceVariant,
          foregroundColor: isPrimary
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          elevation: isPrimary ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
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

class ShakeAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const ShakeAnimatedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  State<ShakeAnimatedIcon> createState() => _ShakeAnimatedIconState();
}

class _ShakeAnimatedIconState extends State<ShakeAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation =
        Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      },
    );
  }
}
