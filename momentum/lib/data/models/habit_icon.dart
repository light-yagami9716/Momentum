import 'package:flutter/material.dart';

class HabitIcon {
  const HabitIcon(this.key, this.icon);

  final String key;
  final IconData icon;

  static const List<HabitIcon> catalog = [
    HabitIcon('water_drop', Icons.water_drop_outlined),
    HabitIcon('book', Icons.menu_book_outlined),
    HabitIcon('fitness', Icons.fitness_center_outlined),
    HabitIcon('directions_run', Icons.directions_run_outlined),
    HabitIcon('bedtime', Icons.bedtime_outlined),
    HabitIcon('school', Icons.school_outlined),
    HabitIcon('self_improvement', Icons.self_improvement_outlined),
    HabitIcon('medication', Icons.medication_outlined),
    HabitIcon('brush', Icons.brush_outlined),
    HabitIcon('wb_sunny', Icons.wb_sunny_outlined),
    HabitIcon('music_note', Icons.music_note_outlined),
    HabitIcon('code', Icons.code_outlined),
    HabitIcon('restaurant', Icons.restaurant_outlined),
    HabitIcon('directions_walk', Icons.directions_walk_outlined),
    HabitIcon('edit_note', Icons.edit_note_outlined),
    HabitIcon('call', Icons.call_outlined),
    HabitIcon('savings', Icons.savings_outlined),
    HabitIcon('cleaning_services', Icons.cleaning_services_outlined),
  ];

  static IconData iconFor(String key) {
    return catalog
        .firstWhere((item) => item.key == key, orElse: () => catalog.first)
        .icon;
  }
}
