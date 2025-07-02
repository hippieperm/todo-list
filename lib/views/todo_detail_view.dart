import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../utils/date_formatter.dart';
import '../utils/animated_priority_button.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/todo_viewmodel.dart';

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
  late bool _useTimeProgress;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _isCompleted = widget.todo.isCompleted;
    _priority = widget.todo.priority;
    _useTimeProgress = widget.todo.useTimeProgress;
    _startTime = widget.todo.startTime;
    _endTime = widget.todo.endTime;
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
              SizedBox(height: 50),
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
              PriorityButtonGroup(
                initialPriority: _priority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _priority = priority;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),

              // 시간 진행률 사용 여부
              Row(
                children: [
                  Switch(
                    value: _useTimeProgress,
                    onChanged: (value) {
                      setState(() {
                        _useTimeProgress = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('시간 진행률 사용'),
                ],
              ),

              // 시간 설정 섹션
              if (_useTimeProgress) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // 시작 시간 설정
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '시작 시간',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDateTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _startTime != null
                            ? DateFormatter.formatDateTime(_startTime!)
                            : '시작 시간 설정',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 종료 시간 설정
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '종료 시간',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDateTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _endTime != null
                            ? DateFormatter.formatDateTime(_endTime!)
                            : '종료 시간 설정',
                      ),
                    ),
                  ],
                ),

                if (_startTime != null && _endTime != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '총 소요 시간: ${_formatDuration(_endTime!.difference(_startTime!))}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
              ],

              const SizedBox(height: 16),

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

  // 시간 선택 다이얼로그
  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartTime
        ? (_startTime ?? now)
        : (_endTime ?? now.add(const Duration(hours: 1)));

    // 날짜 선택
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      // 시간 선택
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (selectedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          if (isStartTime) {
            _startTime = newDateTime;
            // 시작 시간이 종료 시간보다 늦으면 종료 시간도 업데이트
            if (_endTime != null && newDateTime.isAfter(_endTime!)) {
              _endTime = newDateTime.add(const Duration(hours: 1));
            }
          } else {
            // 종료 시간이 시작 시간보다 빠르면 경고
            if (_startTime != null && newDateTime.isBefore(_startTime!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('종료 시간은 시작 시간보다 늦어야 합니다')),
              );
            } else {
              _endTime = newDateTime;
            }
          }
        });
      }
    }
  }

  // 시간 차이를 포맷팅
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return '$twoDigitHours시간 $twoDigitMinutes분 $twoDigitSeconds초';
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

    // 시간 진행률을 사용하는 경우 시작/종료 시간 검증
    if (_useTimeProgress && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시작 시간과 종료 시간을 모두 설정해주세요')));
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
      startTime: _useTimeProgress ? _startTime : null,
      endTime: _useTimeProgress ? _endTime : null,
      useTimeProgress: _useTimeProgress,
    );

    // 저장
    viewModel.updateTodo(updatedTodo);
    Navigator.pop(context);
  }

  void _deleteTodo() {
    showGeneralDialog(
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
                    '"${widget.todo.title}"',
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
                  onPressed: () => Navigator.pop(context),
                  isPrimary: false,
                ),
                const SizedBox(width: 12),
                _buildDialogButton(
                  context: context,
                  label: '삭제',
                  onPressed: () {
                    final viewModel = Provider.of<TodoViewModel>(
                      context,
                      listen: false,
                    );
                    viewModel.deleteTodo(widget.todo.id);
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.pop(context); // 상세 화면 닫기
                  },
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
