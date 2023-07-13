import 'dart:collection';
import 'dart:math';

import 'package:calendar_app_flutter/domain/entity/event.dart';
import 'package:calendar_app_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventApiClient {
  Future<LinkedHashMap<DateTime, List<Event>>> getMeetingRoom(
      String titileMettingRoom) async {
    final int count = Random().nextInt(6) + 3;
    final kEventSource = {
      for (var item in List.generate(50, (index) => index))
        DateTime.utc(kFirstDay.year, kFirstDay.month, item * count):
            List.generate(
                item % 4 + 1,
                (index) => Event(
                    title: '${titileMettingRoom} Event $item | ${index + 10}',
                    date: DateTime.utc(
                        kFirstDay.year, kFirstDay.month, item * count),
                    time: const TimeOfDay(hour: 8, minute: 00)))
    }..addAll({
        kToday: [
          Event(
              title: 'Today\'s Event 1 ${titileMettingRoom}',
              date: kToday,
              time: const TimeOfDay(hour: 10, minute: 00)),
          Event(
              title: 'Today\'s Event 2 ${titileMettingRoom}',
              date: kToday,
              time: const TimeOfDay(hour: 17, minute: 00)),
          Event(
              title: 'Today\'s Event 5 ${titileMettingRoom}',
              date: kToday,
              time: const TimeOfDay(hour: 12, minute: 30)),
        ],
      });
    final loadingEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEventSource);
    await Future.delayed(const Duration(seconds: 1), () => "Hello Dart");
    return loadingEvents;
  }

  Future<List<String>> getTitleRooms() async {
    final List<String> meetingRoomsList = <String>[
      'Переговорная на 1 этаже',
      'Переговорная на 21 этаже',
      'Переговорная на 22 этаже',
      'Переговорная на 23 этаже',
      'Переговорная на 24 этаже',
      'Переговорная на 25 этаже',
      'Переговорная на 26 этаже',
      'Переговорная на 27 этаже',
      'Переговорная на 28 этаже',
      'Переговорная на 29 этаже',
      'Переговорная на 222 этаже',
      'Переговорная на 233 этаже',
      'Переговорная на 244 этаже',
      'Переговорная на 255 этаже',
      'Переговорная на 266 этаже',
      'Переговорная на 277 этаже',
      'Переговорная на 288 этаже',
      'Переговорная на 299 этаже',
      'Переговорная на 1 этаже новый корпус',
      'Переговорная на 2 этаже новый корпус'
    ];
    await Future.delayed(const Duration(seconds: 1), () => "Hello Dart");
    return meetingRoomsList;
  }
}
