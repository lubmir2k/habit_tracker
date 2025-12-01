import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';

/// Home screen - main dashboard showing habits and daily progress.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Habit> _habits = [];
  Set<String> _completedHabitIds = {};
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final storageService = await StorageService.getInstance();
      final habits = storageService.getHabits();
      final completions = storageService.getCompletionsForDate(_selectedDate);
      final completedIds = completions.map((c) => c.habitId).toSet();
      final user = storageService.getCurrentUser();

      if (!mounted) return;
      setState(() {
        _habits = habits;
        _completedHabitIds = completedIds;
        _userName = user?.name;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load habits.')),
      );
    }
  }

  Future<void> _toggleHabitCompletion(String habitId) async {
    final storageService = await StorageService.getInstance();
    final isCompleted = _completedHabitIds.contains(habitId);

    if (isCompleted) {
      await storageService.uncompleteHabit(habitId, _selectedDate);
      if (mounted) {
        setState(() => _completedHabitIds.remove(habitId));
      }
    } else {
      await storageService.completeHabit(habitId, _selectedDate);
      if (mounted) {
        setState(() => _completedHabitIds.add(habitId));
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  List<DateTime> _getWeekDates() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_userName != null ? 'Hi, $_userName!' : AppConstants.appName),
      ),
      drawer: AppDrawer(onProfileReturn: _loadData),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  _buildWelcomeMessage(theme),
                  _buildDateSelector(theme),
                  _buildMotivationalQuote(theme),
                  if (_habits.isEmpty)
                    _buildEmptyState(theme)
                  else
                    _buildHabitsSections(theme),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-habit');
          if (mounted && result == true) {
            _loadData();
          }
        },
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeMessage(ThemeData theme) {
    final greeting = _userName != null
        ? 'Welcome back, $_userName!'
        : 'Welcome to Habit Tracker!';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        greeting,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    final weekDates = _getWeekDates();
    final today = DateTime.now();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday && !isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayAbbreviation(date.weekday),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMotivationalQuote(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            '"The secret of getting ahead is getting started."',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '— Mark Twain',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first habit',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsSections(ThemeData theme) {
    final todoHabits =
        _habits.where((h) => !_completedHabitIds.contains(h.id)).toList();
    final doneHabits =
        _habits.where((h) => _completedHabitIds.contains(h.id)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // To Do Section
          Text(
            'To Do',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (todoHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'All done for today!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            ...todoHabits.map((habit) => _buildHabitCard(habit, false, theme)),

          const SizedBox(height: 16),

          // Done Section
          Text(
            'Done',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (doneHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Swipe left on a habit to mark it done',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            ...doneHabits.map((habit) => _buildHabitCard(habit, true, theme)),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, bool isCompleted, ThemeData theme) {
    return Dismissible(
      key: Key(habit.id),
      direction: isCompleted
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: isCompleted ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          isCompleted ? Icons.undo : Icons.check,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        await _toggleHabitCompletion(habit.id);
        return false; // Don't actually dismiss, just toggle
      },
      child: Card(
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
          title: Text(
            habit.name,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? theme.colorScheme.outline : null,
            ),
          ),
          trailing: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
