part of 'events_bloc.dart';

abstract class EventListEvent {}

class EventListEventLoad extends EventListEvent {
  late final ValueNotifier<List<Event>> selectedEventsWidget;
  late final Set<DateTime> selectedDaysWidget;
  late final List<Event> Function(Iterable<DateTime> days)
      getEventsForDaysWidget;

  EventListEventLoad({
    required this.selectedEventsWidget,
    required this.selectedDaysWidget,
    required this.getEventsForDaysWidget,
  });
}

class EventListEventAdd extends EventListEvent {
  late final Event event;
  late final DateTime day;
  late final ValueNotifier<List<Event>> selectedEventsWidget;
  late final Set<DateTime> selectedDaysWidget;
  late final List<Event> Function(Iterable<DateTime> days)
      getEventsForDaysWidget;

  EventListEventAdd({
    required this.event,
    required this.day,
    required this.selectedEventsWidget,
    required this.selectedDaysWidget,
    required this.getEventsForDaysWidget,
  });
}
