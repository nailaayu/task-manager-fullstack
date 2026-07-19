import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditForm(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _confirmDelete(Task task) async {
    final id = task.id;
    if (id == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Task',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "${task.title}"?',
          style: const TextStyle(
            color: textMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await context.read<TaskProvider>().deleteTask(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil dihapus'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _updateStatus(Task task, TaskStatus status) async {
    final id = task.id;
    if (id == null) return;

    try {
      await context.read<TaskProvider>().updateTaskStatus(id, status);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    await context.read<TaskProvider>().searchTasks(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final todo = provider.getTasksByStatus(TaskStatus.todo).length;
        final progress = provider.getTasksByStatus(TaskStatus.inProgress).length;
        final done = provider.getTasksByStatus(TaskStatus.done).length;

        return RefreshIndicator(
          color: primaryBlue,
          onRefresh: provider.loadTasks,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Todo',
                              value: todo,
                              icon: Icons.radio_button_unchecked_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Progress',
                              value: progress,
                              icon: Icons.sync_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Done',
                              value: done,
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFD6E4FF),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x102563EB),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: 'Cari task...',
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: primaryBlue,
                                      ),
                                      suffixIcon: _searchController.text.isEmpty
                                          ? null
                                          : IconButton(
                                              color: primaryBlue,
                                              icon: const Icon(
                                                Icons.clear_rounded,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                provider.loadTasks();
                                                setState(() {});
                                              },
                                            ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD6E4FF),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: const BorderSide(
                                          color: primaryBlue,
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    onSubmitted: (_) => _search(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: _search,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Icon(Icons.search_rounded),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<TaskStatus?>(
                                    value: provider.selectedStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'Status',
                                    ),
                                    items: [
                                      const DropdownMenuItem<TaskStatus?>(
                                        value: null,
                                        child: Text('Semua'),
                                      ),
                                      ...TaskStatus.values.map(
                                        (status) =>
                                            DropdownMenuItem<TaskStatus?>(
                                          value: status,
                                          child: Text(status.label),
                                        ),
                                      ),
                                    ],
                                    onChanged: provider.filterByStatus,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<TaskCategory?>(
                                    value: provider.selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Kategori',
                                    ),
                                    items: [
                                      const DropdownMenuItem<TaskCategory?>(
                                        value: null,
                                        child: Text('Semua'),
                                      ),
                                      ...TaskCategory.values.map(
                                        (category) =>
                                            DropdownMenuItem<TaskCategory?>(
                                          value: category,
                                          child: Text(category.label),
                                        ),
                                      ),
                                    ],
                                    onChanged: provider.filterByCategory,
                                  ),
                                ),
                              ],
                            ),
                            if (provider.searchQuery.isNotEmpty ||
                                provider.selectedStatus != null ||
                                provider.selectedCategory != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearFilters();
                                    setState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryBlue,
                                  ),
                                  child: const Text('Reset filter'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                    ),
                  ),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: provider.error!,
                    onRetry: provider.loadTasks,
                  ),
                )
              else if (provider.tasks.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = provider.tasks[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            onEdit: () => _openEditForm(task),
                            onDelete: () => _confirmDelete(task),
                            onStatusChanged: (status) {
                              _updateStatus(task, status);
                            },
                          ),
                        );
                      },
                      childCount: provider.tasks.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6E4FF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2563EB),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan tombol Tambah Task untuk membuat task pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFECACA),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}