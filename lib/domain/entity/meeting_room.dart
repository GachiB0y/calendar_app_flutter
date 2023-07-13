import 'dart:collection';

import 'package:calendar_app_flutter/domain/entity/event.dart';

class MeetingRoom {
  final String title;
  final LinkedHashMap<DateTime, List<Event>> kEvents;

  const MeetingRoom({required this.title, required this.kEvents});

  @override
  String toString() => title;
}
