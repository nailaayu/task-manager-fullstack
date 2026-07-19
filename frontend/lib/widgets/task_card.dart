import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<TaskStatus> onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color borderBlue = Color(0xFFBFDBFE);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final category = task.category ?? TaskCategory.other;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFD6E4FF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102563EB),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  bottomLeft: Radius.circular(26),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: softBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _statusIcon(task.status),
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (task.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: textMuted,
                                    fontSize: 14,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: textDark,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    color: primaryBlue,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: _statusIcon(task.status),
                          label: task.status.label,
                        ),
                        _InfoChip(
                          icon: _categoryIcon(category),
                          label: category.label,
                        ),
                        if (task.dueDate != null)
                          _InfoChip(
                            icon: Icons.calendar_month_rounded,
                            label: _formatDate(task.dueDate!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD6E4FF),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TaskStatus>(
                          value: task.status,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(18),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: textMuted,
                          ),
                          items: TaskStatus.values
                              .map(
                                (status) => DropdownMenuItem<TaskStatus>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Ubah status',
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        status.label,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onStatusChanged(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.sync_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  IconData _categoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.other:
        return Icons.widgets_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color borderBlue = Color(0xFFBFDBFE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderBlue,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}