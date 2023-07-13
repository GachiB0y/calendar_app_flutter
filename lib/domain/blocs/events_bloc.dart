import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:calendar_app_flutter/domain/api_client/event_api_client.dart';
import 'package:calendar_app_flutter/domain/entity/meetingRoom.dart';
import 'package:calendar_app_flutter/domain/repository/event_repositort.dart';
import 'package:calendar_app_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../entity/event.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventListViewBloc extends Bloc<EventListEvent, EventListState> {
  final _eventApiClient = EventApiClient();
  final EventsRepository eventsRepository = EventsRepository();

  EventListViewBloc() : super(EventInitial()) {
    on<EventListEvent>(
      (event, emit) async {
        if (event is EventListEventLoad) {
          final kEventSource = {
            for (var item in List.generate(50, (index) => index))
              DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5):
                  List.generate(
                      item % 4 + 1,
                      (index) => Event(
                          title: 'Event $item | ${index + 1}',
                          date: DateTime.utc(
                              kFirstDay.year, kFirstDay.month, item * 5),
                          time: const TimeOfDay(hour: 8, minute: 00)))
          }..addAll({
              kToday: [
                Event(
                    title: 'Today\'s Event 1',
                    date: kToday,
                    time: const TimeOfDay(hour: 10, minute: 00)),
                Event(
                    title: 'Today\'s Event 2',
                    date: kToday,
                    time: const TimeOfDay(hour: 17, minute: 00)),
                Event(
                    title: 'Today\'s Event 5',
                    date: kToday,
                    time: const TimeOfDay(hour: 12, minute: 30)),
              ],
            });
          final loadingEvents = LinkedHashMap<DateTime, List<Event>>(
            equals: isSameDay,
            hashCode: getHashCode,
          )..addAll(kEventSource);
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
          final MeetingRoom meetingRoom =
              MeetingRoom(kEvents: loadingEvents, title: meetingRoomsList[0]);
          await Future.delayed(const Duration(seconds: 1), () => "Hello Dart");

          emit(EventListLoaded(
              meetingRoom: meetingRoom, listNameRooms: meetingRoomsList));
          event.selectedEventsWidget.value =
              event.getEventsForDaysWidget(event.selectedDaysWidget);
        } else if (event is EventListEventAdd) {
          addEventForDay(event, emit);
        } else if (event is EventChangeMeetingRoom) {
          emit(EventIsLoading());
          await changeMeetingRoom(event, emit);
        }
      },
    );
  }

  Future<void> onFriendListEventLoad(
      EventListEventAdd event, Emitter<EventListState> emit) async {}

  void addEventForDay(EventListEventAdd event, Emitter<EventListState> emit) {
    if (state.meetingRoom.kEvents[event.day] == null) {
      final eventsList = <Event>[];
      eventsList.add(event.event);
      final Map<DateTime, List<Event>> kEventSource = {
        event.day!: eventsList,
      };
      state.meetingRoom.kEvents.addAll(kEventSource);
    } else {
      state.meetingRoom.kEvents[event.day]!.add(event.event);
    }
    event.selectedEventsWidget.value =
        event.getEventsForDaysWidget(event.selectedDayWidget);
  }

  Future<void> changeMeetingRoom(
      EventChangeMeetingRoom event, Emitter<EventListState> emit) async {
    final titileMettingRoom = event.titileMettingRoom;

    final kEvent = await _eventApiClient.getMeetingRoom(titileMettingRoom);
    final MeetingRoom room =
        MeetingRoom(kEvents: kEvent, title: titileMettingRoom);
    final listNameRooms = await _eventApiClient.getTitleRooms();

    emit(EventListLoaded(meetingRoom: room, listNameRooms: listNameRooms));
    event.selectedEventsWidget.value =
        event.getEventsForDaysWidget(event.selectedDayWidget);
  }
}
