part of 'events_bloc.dart';

abstract class EventListState {
  // final LinkedHashMap<DateTime, List<Event>> kEvents =
  //     LinkedHashMap<DateTime, List<Event>>(
  //   equals: isSameDay,
  //   hashCode: getHashCode,
  // );

  MeetingRoom meetingRoom = MeetingRoom(
      kEvents: LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      ),
      title: '');

  final List<String> listNameRooms = [];
}

class EventListLoaded extends EventListState {
  @override
  final MeetingRoom meetingRoom;
  @override
  final List<String> listNameRooms;

  EventListLoaded({
    required this.meetingRoom,
    required this.listNameRooms,
    //  required LinkedHashMap<DateTime, List<Event>> kEvents,
  });

  EventListLoaded copyWith({
    MeetingRoom? meetingRoom,
    List<String>? listNameRooms,
  }) {
    return EventListLoaded(
      meetingRoom: meetingRoom ?? this.meetingRoom,
      listNameRooms: listNameRooms ?? this.listNameRooms,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventListLoaded &&
          runtimeType == other.runtimeType &&
          meetingRoom == other.meetingRoom &&
          listNameRooms == other.listNameRooms;

  @override
  int get hashCode => meetingRoom.hashCode;
}

class EventInitial extends EventListState {}

class EventIsError extends EventListState {}

class EventIsLoading extends EventListState {}
