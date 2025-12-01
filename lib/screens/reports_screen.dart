import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';

/// Reports screen showing weekly habit progress and statistics.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];

  // Weekly data
  late List<DateTime> _weekDates;
  Map<String, int> _dailyCompletions = {};
  Map<String, int> _habitCompletionCounts = {};

  @override
  void initState() {
    super.initState();
    _initWeekDates();
    _loadData();
  }

  void _initWeekDates() {
    final today = DateTime.now();
    // Get the start of this week (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    _weekDates = List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
  }

  Future<void> _loadData() async {
    final storageService = await StorageService.getInstance();
    final habits = storageService.getHabits();
    final completions = storageService.getAllCompletions();

    // Calculate daily completions for the week
    final dailyCompletions = <String, int>{};
    for (final date in _weekDates) {
      final dateKey = HabitCompletion.formatDateKey(date);
      dailyCompletions[dateKey] =
          completions.where((c) => c.dateKey == dateKey).length;
    }

    // Calculate per-habit completion counts for the week
    final habitCounts = <String, int>{};
    for (final habit in habits) {
      habitCounts[habit.id] = completions
          .where((c) =>
              c.habitId == habit.id &&
              _weekDates.any((d) => HabitCompletion.formatDateKey(d) == c.dateKey))
          .length;
    }

    if (mounted) {
      setState(() {
        _habits = habits;
        _completions = completions;
        _dailyCompletions = dailyCompletions;
        _habitCompletionCounts = habitCounts;
        _isLoading = false;
      });
    }
  }

  int get _totalCompletions {
    return _dailyCompletions.values.fold(0, (sum, count) => sum + count);
  }

  int get _maxPossibleCompletions {
    return _habits.length * 7;
  }

  double get _completionRate {
    if (_maxPossibleCompletions == 0) return 0;
    return (_totalCompletions / _maxPossibleCompletions) * 100;
  }

  String get _bestDay {
    if (_dailyCompletions.isEmpty) return '-';

    String bestDateKey = _dailyCompletions.keys.first;
    int maxCount = _dailyCompletions.values.first;

    for (final entry in _dailyCompletions.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestDateKey = entry.key;
      }
    }

    if (maxCount == 0) return '-';

    // Convert date key to day name
    final dateParts = bestDateKey.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
    return _getDayName(date.weekday);
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeeklyProgressSection(theme),
                        const SizedBox(height: 24),
                        _buildStatisticsCard(theme),
                        const SizedBox(height: 24),
                        _buildHabitBreakdownSection(theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some habits to see your progress reports',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _habits.isEmpty
                  ? 5
                  : (_habits.length.toDouble() + 1).clamp(5, 20),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} completed',
                      TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < _weekDates.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getDayName(_weekDates[index].weekday),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == value.roundToDouble()) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: _buildBarGroups(theme),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(_weekDates.length, (index) {
      final date = _weekDates[index];
      final dateKey = HabitCompletion.formatDateKey(date);
      final count = _dailyCompletions[dateKey] ?? 0;
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: isToday
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _buildStatisticsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildStatRow(
              theme,
              Icons.check_circle,
              'Total Completed',
              '$_totalCompletions',
            ),
            _buildStatRow(
              theme,
              Icons.percent,
              'Completion Rate',
              '${_completionRate.toStringAsFixed(0)}%',
            ),
            _buildStatRow(
              theme,
              Icons.star,
              'Best Day',
              _bestDay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitBreakdownSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._habits.map((habit) => _buildHabitRow(theme, habit)),
      ],
    );
  }

  Widget _buildHabitRow(ThemeData theme, Habit habit) {
    final count = _habitCompletionCounts[habit.id] ?? 0;
    final progress = count / 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 40,
              decoration: BoxDecoration(
                color: habit.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: habit.color,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count/7',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
