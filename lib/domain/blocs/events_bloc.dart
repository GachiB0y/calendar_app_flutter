import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:calendar_app_flutter/domain/api_client/event_api_client.dart';
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
                          time: TimeOfDay(hour: 8, minute: 00)))
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
          await Future.delayed(const Duration(seconds: 3), () => "Hello Dart");
          emit(EventListLoaded(kEvents: loadingEvents));
          event.selectedEventsWidget.value =
              event.getEventsForDaysWidget(event.selectedDaysWidget);
        } else if (event is EventListEventAdd) {
          addEventForDay(event, emit);
        }
      },
    );
  }

  Future<void> onFriendListEventLoad(
      EventListEventAdd event, Emitter<EventListState> emit) async {}

  void addEventForDay(EventListEventAdd event, Emitter<EventListState> emit) {
    if (state.kEvents[event.day] == null) {
      final eventsList = <Event>[];
      eventsList.add(event.event);
      final Map<DateTime, List<Event>> kEventSource = {
        event.day!: eventsList,
      };
      state.kEvents.addAll(kEventSource);
    } else {
      state.kEvents[event.day]!.add(event.event);
    }
    event.selectedEventsWidget.value =
        event.getEventsForDaysWidget(event.selectedDayWidget);
  }
}
