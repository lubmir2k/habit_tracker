import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback_helper.dart';

/// Screen for configuring habits - add new and manage existing.
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  bool _isSaving = false;
  bool _habitsChanged = false;
  List<Habit> _existingHabits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final storageService = await StorageService.getInstance();
    setState(() {
      _existingHabits = storageService.getHabits();
    });
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final storageService = await StorageService.getInstance();
      final habit = Habit(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        colorValue: AppConstants.defaultHabitColors[_selectedColorIndex],
        createdAt: DateTime.now(),
      );

      final success = await storageService.addHabit(habit);

      if (mounted) {
        if (success) {
          _habitsChanged = true;
          _nameController.clear();
          _loadHabits();
          FeedbackHelper.showSuccess(context, 'Habit added');
        } else {
          FeedbackHelper.showError(context, 'Failed to save habit');
        }
      }
    } catch (e) {
      if (mounted) {
        FeedbackHelper.showError(context, 'An error occurred while saving.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storageService = await StorageService.getInstance();
      final success = await storageService.deleteHabit(habit.id);

      if (mounted) {
        if (success) {
          _habitsChanged = true;
          _loadHabits();
          FeedbackHelper.showSuccess(context, 'Habit deleted');
        } else {
          FeedbackHelper.showError(context, 'Failed to delete habit');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_habitsChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configure Habits'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add New Habit Section
              Text(
                'Add New Habit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Exercise, Read, Meditate',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  if (value.trim().length < 2) {
                    return 'Habit name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Choose a Color',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(
                  AppConstants.defaultHabitColors.length,
                  (index) => _buildColorOption(index, theme),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Add',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.prebuiltHabits.map((habit) {
                  return ActionChip(
                    label: Text(habit),
                    onPressed: () {
                      _nameController.text = habit;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveHabit,
                icon: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Add'),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Existing Habits Section
              Text(
                'Existing Habits',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_existingHabits.isEmpty)
                const EmptyState(
                  icon: Icons.format_list_bulleted,
                  title: 'No habits yet',
                  subtitle: 'Add your first habit above!',
                )
              else
                ..._existingHabits.map((habit) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 12,
                          height: 40,
                          decoration: BoxDecoration(
                            color: habit.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(habit.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteHabit(habit),
                          tooltip: 'Delete habit',
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(int index, ThemeData theme) {
    final color = Color(AppConstants.defaultHabitColors[index]);
    final isSelected = _selectedColorIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}
