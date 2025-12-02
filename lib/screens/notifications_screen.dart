import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/notification_settings.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';

/// Notifications screen for managing notification settings.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  NotificationSettings _settings = const NotificationSettings();
  List<Habit> _habits = [];
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storageService = await StorageService.getInstance();
    final settings = storageService.getNotificationSettings();
    final habits = storageService.getHabits();

    if (mounted) {
      setState(() {
        _storageService = storageService;
        _settings = settings;
        _habits = habits;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });
    await _storageService?.saveNotificationSettings(newSettings);
  }

  Future<void> _showTimePicker(
    String slot,
    int currentHour,
    int currentMinute,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (time != null) {
      NotificationSettings newSettings;
      switch (slot) {
        case 'morning':
          newSettings = _settings.copyWith(
            morningHour: time.hour,
            morningMinute: time.minute,
          );
          break;
        case 'afternoon':
          newSettings = _settings.copyWith(
            afternoonHour: time.hour,
            afternoonMinute: time.minute,
          );
          break;
        case 'evening':
          newSettings = _settings.copyWith(
            eveningHour: time.hour,
            eveningMinute: time.minute,
          );
          break;
        default:
          return;
      }
      await _updateSettings(newSettings);
    }
  }

  void _toggleHabitNotification(String habitId, bool enabled) {
    final newEnabledIds = Set<String>.from(_settings.enabledHabitIds);
    if (enabled) {
      newEnabledIds.add(habitId);
    } else {
      newEnabledIds.remove(habitId);
    }
    _updateSettings(_settings.copyWith(enabledHabitIds: newEnabledIds));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalToggle(theme),
                  const SizedBox(height: 24),
                  _buildReminderTimesSection(theme),
                  const SizedBox(height: 24),
                  _buildHabitRemindersSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildGlobalToggle(ThemeData theme) {
    return Card(
      child: SwitchListTile(
        title: Text(
          'Enable Notifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _settings.globalEnabled
              ? 'Notifications are enabled'
              : 'Notifications are disabled',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        value: _settings.globalEnabled,
        onChanged: (value) {
          _updateSettings(_settings.copyWith(globalEnabled: value));
        },
        secondary: Icon(
          _settings.globalEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: _settings.globalEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildReminderTimesSection(ThemeData theme) {
    final isEnabled = _settings.globalEnabled;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder Times',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildTimeSlotRow(
                  theme,
                  icon: Icons.wb_sunny_outlined,
                  label: 'Morning',
                  timeString: _settings.morningTimeString,
                  enabled: _settings.morningEnabled,
                  onToggle: isEnabled
                      ? (value) {
                          _updateSettings(
                              _settings.copyWith(morningEnabled: value));
                        }
                      : null,
                  onTimeTap: isEnabled && _settings.morningEnabled
                      ? () => _showTimePicker(
                            'morning',
                            _settings.morningHour,
                            _settings.morningMinute,
                          )
                      : null,
                ),
                const Divider(height: 1),
                _buildTimeSlotRow(
                  theme,
                  icon: Icons.wb_sunny,
                  label: 'Afternoon',
                  timeString: _settings.afternoonTimeString,
                  enabled: _settings.afternoonEnabled,
                  onToggle: isEnabled
                      ? (value) {
                          _updateSettings(
                              _settings.copyWith(afternoonEnabled: value));
                        }
                      : null,
                  onTimeTap: isEnabled && _settings.afternoonEnabled
                      ? () => _showTimePicker(
                            'afternoon',
                            _settings.afternoonHour,
                            _settings.afternoonMinute,
                          )
                      : null,
                ),
                const Divider(height: 1),
                _buildTimeSlotRow(
                  theme,
                  icon: Icons.nightlight_round,
                  label: 'Evening',
                  timeString: _settings.eveningTimeString,
                  enabled: _settings.eveningEnabled,
                  onToggle: isEnabled
                      ? (value) {
                          _updateSettings(
                              _settings.copyWith(eveningEnabled: value));
                        }
                      : null,
                  onTimeTap: isEnabled && _settings.eveningEnabled
                      ? () => _showTimePicker(
                            'evening',
                            _settings.eveningHour,
                            _settings.eveningMinute,
                          )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String timeString,
    required bool enabled,
    required void Function(bool)? onToggle,
    required VoidCallback? onTimeTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: enabled && onTimeTap != null
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeString,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: enabled && onTimeTap != null
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRemindersSection(ThemeData theme) {
    final isEnabled = _settings.globalEnabled;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Reminders',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which habits to receive reminders for',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          _habits.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No habits yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add habits to set up reminders',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Card(
                  child: Column(
                    children: _habits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final habit = entry.value;
                      final isHabitEnabled =
                          _settings.enabledHabitIds.contains(habit.id);

                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 1),
                          SwitchListTile(
                            title: Text(habit.name),
                            value: isHabitEnabled,
                            onChanged: isEnabled
                                ? (value) =>
                                    _toggleHabitNotification(habit.id, value)
                                : null,
                            secondary: Container(
                              width: 12,
                              height: 40,
                              decoration: BoxDecoration(
                                color: habit.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
