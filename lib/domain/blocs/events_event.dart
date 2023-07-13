part of 'events_bloc.dart';

abstract class EventListEvent {}

class EventListEventLoad extends EventListEvent {
  late final ValueNotifier<List<Event>> selectedEventsWidget;
  late final DateTime? selectedDaysWidget;
  late final List<Event> Function(DateTime? days) getEventsForDaysWidget;

  EventListEventLoad({
    required this.selectedEventsWidget,
    required this.selectedDaysWidget,
    required this.getEventsForDaysWidget,
  });
}

class EventListEventAdd extends EventListEvent {
  late final Event event;
  late final DateTime? day;
  late final ValueNotifier<List<Event>> selectedEventsWidget;
  late final DateTime? selectedDayWidget;
  late final List<Event> Function(DateTime? days) getEventsForDaysWidget;

  EventListEventAdd({
    required this.event,
    required this.day,
    required this.selectedEventsWidget,
    required this.selectedDayWidget,
    required this.getEventsForDaysWidget,
  });
}

class EventChangeMeetingRoom extends EventListEvent {
  late final String titileMettingRoom;
  late final ValueNotifier<List<Event>> selectedEventsWidget;
  late final DateTime? selectedDayWidget;
  late final List<Event> Function(DateTime? days) getEventsForDaysWidget;

  EventChangeMeetingRoom({
    required this.titileMettingRoom,
    required this.selectedEventsWidget,
    required this.selectedDayWidget,
    required this.getEventsForDaysWidget,
  });
}
