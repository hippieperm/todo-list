import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/viewmodels/theme_viewmodel.dart';
import 'package:todo/viewmodels/todo_viewmodel.dart';
import 'package:todo/views/todo_add_view.dart';
import 'package:todo/views/todo_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = Provider.of<TodoViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 목록'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeViewModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeViewModel.toggleThemeMode();
            },
            tooltip: themeViewModel.isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 검색창
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '검색...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    viewModel.setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 16),

                // 필터 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton(context, '전체', 'all', viewModel),
                    _buildFilterButton(context, '완료', 'completed', viewModel),
                    _buildFilterButton(context, '미완료', 'incomplete', viewModel),
                  ],
                ),
              ],
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

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    String filterValue,
    TodoViewModel viewModel,
  ) {
    final isSelected = viewModel.filter == filterValue;
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: () {
        viewModel.setFilter(filterValue);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? colorScheme.primary : Colors.transparent,
        foregroundColor: isSelected
            ? colorScheme.onPrimary
            : colorScheme.primary,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : colorScheme.primary,
        ),
      ),
      child: Text(label),
    );
  }
}
