import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

/// Screen for adding a new habit.
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save habit')),
          );
          setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _saveHabit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Habit'),
            ),
          ],
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
