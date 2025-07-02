import 'package:flutter/material.dart';

class AnimatedPriorityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final AnimationController animationController;
  final VoidCallback onTap;

  const AnimatedPriorityButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        // 선택 시 애니메이션 재시작
        animationController.reset();
        animationController.forward();
      },
      child: isSelected ? _buildAnimatedButton() : _buildButtonContent(),
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeOutBack,
                ),
              ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOutBack,
              ),
            ),
            child: _buildButtonContent(),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    return Container(
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
          Icon(icon, color: isSelected ? color : Colors.grey),
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
    );
  }
}

class PriorityButtonGroup extends StatefulWidget {
  final int initialPriority;
  final Function(int) onPriorityChanged;
  final bool isDarkMode;

  const PriorityButtonGroup({
    super.key,
    required this.initialPriority,
    required this.onPriorityChanged,
    required this.isDarkMode,
  });

  @override
  State<PriorityButtonGroup> createState() => _PriorityButtonGroupState();
}

class _PriorityButtonGroupState extends State<PriorityButtonGroup>
    with SingleTickerProviderStateMixin {
  late int _priority;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _priority = widget.initialPriority;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityButton(
          context,
          '낮음',
          1,
          widget.isDarkMode ? Colors.green.shade300 : Colors.green,
        ),
        const SizedBox(width: 8),
        _buildPriorityButton(
          context,
          '중간',
          2,
          widget.isDarkMode ? Colors.orange.shade300 : Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildPriorityButton(
          context,
          '높음',
          3,
          widget.isDarkMode ? Colors.red.shade300 : Colors.red,
        ),
      ],
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
      child: AnimatedPriorityButton(
        label: label,
        icon: Icons.flag,
        color: color,
        isSelected: isSelected,
        animationController: _animationController,
        onTap: () {
          setState(() {
            _priority = priority;
          });
          widget.onPriorityChanged(priority);
        },
      ),
    );
  }
}
