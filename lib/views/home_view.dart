import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/todo_viewmodel.dart';
import 'todo_add_view.dart';
import 'todo_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = Provider.of<TodoViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '검색...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) {
                  viewModel.setSearchQuery(value);
                },
              )
            : const Text('할 일 목록'),
        centerTitle: !_isSearching,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    viewModel.setSearchQuery('');
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  viewModel.setSearchQuery('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 영역
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterSegmentedControl(context, viewModel),
            ),
          ),

          // 할 일 목록
          const Expanded(child: TodoListView()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoAddView()),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSegmentedControl(
    BuildContext context,
    TodoViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentFilter = viewModel.filter;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildFilterTab(
              context: context,
              label: '전체',
              icon: Icons.list_alt,
              filterValue: 'all',
              isSelected: currentFilter == 'all',
              onTap: () => viewModel.setFilter('all'),
            ),
            _buildFilterTab(
              context: context,
              label: '완료',
              icon: Icons.check_circle,
              filterValue: 'completed',
              isSelected: currentFilter == 'completed',
              onTap: () => viewModel.setFilter('completed'),
            ),
            _buildFilterTab(
              context: context,
              label: '미완료',
              icon: Icons.radio_button_unchecked,
              filterValue: 'incomplete',
              isSelected: currentFilter == 'incomplete',
              onTap: () => viewModel.setFilter('incomplete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String filterValue,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap();
          _animationController.reset();
          _animationController.forward();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withOpacity(0.7),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
