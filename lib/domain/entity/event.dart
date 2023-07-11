import 'package:flutter/material.dart';

/// Example event class.
class Event {
  final String title;
  final DateTime? date;
  final TimeOfDay? time;

  const Event({required this.title, this.date, this.time});

  @override
  String toString() => title;
}
