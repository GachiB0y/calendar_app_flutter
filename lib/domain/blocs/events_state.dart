part of 'events_bloc.dart';

abstract class EventListState {
  final LinkedHashMap<DateTime, List<Event>> kEvents =
      LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
}

class EventListLoaded extends EventListState {
  @override
  LinkedHashMap<DateTime, List<Event>> kEvents;

  // EventListLoaded.initial()
  //     : kEvents = LinkedHashMap<DateTime, List<Event>>(
  //           equals: isSameDay, hashCode: getHashCode);

  EventListLoaded({
    required this.kEvents,
  });

  EventListLoaded copyWith({
    LinkedHashMap<DateTime, List<Event>>? kEvents,
  }) {
    return EventListLoaded(
      kEvents: kEvents ?? this.kEvents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventListLoaded &&
          runtimeType == other.runtimeType &&
          kEvents == other.kEvents;

  @override
  int get hashCode => kEvents.hashCode;
}

class EventInitial extends EventListState {}

class EventIsError extends EventListState {}
