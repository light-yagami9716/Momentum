enum HabitFrequency { daily, specificDays }

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorIndex,
    required this.frequency,
    required this.days,
    required this.createdDate,
    this.reminderMinutes,
    this.archived = false,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorIndex;
  final HabitFrequency frequency;
  final List<int> days;
  final DateTime createdDate;
  final int? reminderMinutes;
  final bool archived;

  bool isScheduledOn(DateTime date) {
    return switch (frequency) {
      HabitFrequency.daily => true,
      HabitFrequency.specificDays => days.contains(date.weekday),
    };
  }

  Habit copyWith({
    String? name,
    String? iconKey,
    int? colorIndex,
    HabitFrequency? frequency,
    List<int>? days,
    DateTime? createdDate,
    int? reminderMinutes,
    bool? archived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorIndex: colorIndex ?? this.colorIndex,
      frequency: frequency ?? this.frequency,
      days: days ?? this.days,
      createdDate: createdDate ?? this.createdDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'colorIndex': colorIndex,
      'frequency': frequency.name,
      'days': days,
      'createdDate':
          '${createdDate.year.toString().padLeft(4, '0')}-'
          '${createdDate.month.toString().padLeft(2, '0')}-'
          '${createdDate.day.toString().padLeft(2, '0')}',
      'reminderMinutes': reminderMinutes,
      'archived': archived,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final createdParts = (json['createdDate'] as String).split('-');
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String? ?? 'fitness',
      colorIndex: json['colorIndex'] as int? ?? 0,
      frequency: json['frequency'] == 'specificDays'
          ? HabitFrequency.specificDays
          : HabitFrequency.daily,
      days: (json['days'] as List? ?? [])
          .whereType<num>()
          .map((day) => day.toInt())
          .toList(),
      createdDate: DateTime(
        int.parse(createdParts[0]),
        int.parse(createdParts[1]),
        int.parse(createdParts[2]),
      ),
      reminderMinutes: json['reminderMinutes'] as int?,
      archived: json['archived'] as bool? ?? false,
    );
  }
}
