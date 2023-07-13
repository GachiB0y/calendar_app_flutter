import 'dart:collection';

import 'package:calendar_app_flutter/domain/api_client/event_api_client.dart';
import 'package:calendar_app_flutter/domain/entity/event.dart';

abstract class IRepo {
  Future<LinkedHashMap<DateTime, List<Event>>> getMeetingRoom(
      String titileMettingRoom);
}

class EventsRepository implements IRepo {
  final EventApiClient characterProvider;

  EventsRepository({required this.characterProvider});

  @override
  Future<LinkedHashMap<DateTime, List<Event>>> getMeetingRoom(
      String titileMettingRoom) {
    return characterProvider.getMeetingRoom(titileMettingRoom);
  }
}
