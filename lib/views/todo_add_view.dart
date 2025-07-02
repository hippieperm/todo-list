import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../utils/date_formatter.dart';
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
  bool _useTimeProgress = false; // 시간 진행률 사용 여부
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _addTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('추가'),
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

    return '$twoDigitHours시간 $twoDigitMinutes분';
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

  Future<void> _addTodo() async {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    // 입력값 검증
    final title = _titleController.text.trim();
    if (title.isEmpty) {
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

    // 로딩 상태 설정
    setState(() {
      _isLoading = true;
    });

    try {
      // 새 할 일 객체 생성
      final newTodo = Todo(
        title: title,
        description: _descriptionController.text.trim(),
        priority: _priority,
        startTime: _useTimeProgress ? _startTime : null,
        endTime: _useTimeProgress ? _endTime : null,
        useTimeProgress: _useTimeProgress,
      );

      // 저장
      final success = await viewModel.addTodo(newTodo);

      if (success) {
        Navigator.pop(context);
      } else {
        // 실패 시 사용자에게 알림
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('할 일을 추가하는 중 오류가 발생했습니다')),
          );
        }
      }
    } catch (e) {
      // 예외 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      }
    } finally {
      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
