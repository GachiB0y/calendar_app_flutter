import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
import 'package:calendar_app_flutter/domain/repository/event_repositort.dart';
import 'package:calendar_app_flutter/utils/config.dart';
import 'package:calendar_app_flutter/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../domain/entity/event.dart';

import '../utils/utils.dart';

class TableComplexBlocLandscapeTest extends StatefulWidget {
  final IRepo repo;
  const TableComplexBlocLandscapeTest({super.key, required this.repo});

  @override
  _TableComplexBlocLandscapeTestState createState() =>
      _TableComplexBlocLandscapeTestState();
}

class _TableComplexBlocLandscapeTestState
    extends State<TableComplexBlocLandscapeTest> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());

  DateTime? _selectedDay;
  DateTime? _selectedDayActive;

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    _selectedDay = _focusedDay.value;
    _selectedDayActive = _focusedDay.value;
    final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
    eventBloc.add(EventListEventLoad(
      getEventsForDaysWidget: _getEventsForDay,
      selectedDaysWidget: _selectedDay,
      selectedEventsWidget: _selectedEvents,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDay != null || _rangeStart != null || _rangeEnd != null;
  List<Event> _getEventsForDay(DateTime? day) {
    final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
    List<Event>? events;
    if (eventBloc.state is EventListLoaded) {
      events = eventBloc.state.meetingRoom.kEvents[day];
    }

    return events ?? [];
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        final dateNow = DateTime(kToday.year, kToday.month, kToday.day);
        final dateSelected =
            DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

        if (dateSelected.isAfter(dateNow) ||
            dateSelected.isAtSameMomentAs(dateNow)) {
          _selectedDayActive = selectedDay;
        } else {
          _selectedDayActive = null;
        }
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   setState(() {
  //     final dateNow = DateTime(kToday.year, kToday.month, kToday.day);
  //     final dateSelected =
  //         DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

  //     if (dateSelected.isAfter(dateNow) ||
  //         dateSelected.isAtSameMomentAs(dateNow)) {
  //       if (_selectedDaysActive.contains(selectedDay)) {
  //         _selectedDaysActive.remove(selectedDay);
  //       } else {
  //         _selectedDaysActive.add(selectedDay);
  //       }
  //     }
  //     if (_selectedDays.contains(selectedDay)) {
  //       _selectedDays.remove(selectedDay);
  //     } else {
  //       _selectedDays.add(selectedDay);
  //     }

  //     _focusedDay.value = focusedDay;
  //     _rangeStart = null;
  //     _rangeEnd = null;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //   });

  //   _selectedEvents.value = _getEventsForDays(_selectedDays);
  // }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDay = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void _addEventsForDay({
    required Event event,
    required DateTime? day,
    required EventListViewBloc eventBloc,
  }) {
    setState(() {
      eventBloc.add(EventListEventAdd(
        event: event,
        day: day,
        getEventsForDaysWidget: _getEventsForDay,
        selectedDayWidget: _selectedDay,
        selectedEventsWidget: _selectedEvents,
      ));
    });
  }

  void _changeTheme() {
    setState(() {
      currentTheme.toggleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    final EventListViewBloc eventBloc = context.watch<EventListViewBloc>();
    return BlocListener<EventListViewBloc, EventListState>(
      listener: (context, state) =>
          EventListViewBloc(eventsRepository: widget.repo),
      child: BlocBuilder<EventListViewBloc, EventListState>(
          builder: (context, state) {
        if (state is EventInitial || state is EventIsLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is EventListLoaded) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: _selectedDayActive != null
                ? FittedBox(
                    child: ValueListenableBuilder<List<Event>>(
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) {
                          return FloatingActionButton.extended(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _AlertDialogAddEventWidget(
                                eventBloc: eventBloc,
                                selectedEvents: value,
                                addEvent: _addEventsForDay,
                                focusedDay: _selectedDay,
                              ),
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: sizeIcon,
                            ),
                            label: const Text(
                              "Добавить",
                              style: TextStyle(fontSize: 28),
                            ),
                          );
                        }),
                  )
                : const SizedBox.shrink(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                      child: DropDownMenuMettingRooms(
                        eventBloc: eventBloc,
                        getEventsForDaysWidget: _getEventsForDay,
                        selectedEventsWidget: _selectedEvents,
                        selectedDayWidget: _selectedDay,
                      ),
                    ),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _focusedDay,
                      builder: (context, value, _) {
                        return _CalendarHeader(
                          focusedDay: value,
                          clearButtonVisible: canClearSelection,
                          onTodayButtonTap: () {
                            setState(() => _focusedDay.value = DateTime.now());
                          },
                          onClearButtonTap: () {
                            setState(() {
                              _rangeStart = null;
                              _rangeEnd = null;
                              _selectedDay = null;
                              _selectedEvents.value = [];
                            });
                          },
                          onLeftArrowTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          onRightArrowTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          changeTheme: _changeTheme,
                        );
                      },
                    ),
                    TableCalendar<Event>(
                      rowHeight: 60,
                      daysOfWeekHeight: 32,
                      calendarStyle: CalendarStyle(
                        todayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeTextCalendar),
                        selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeTextCalendar),
                        outsideTextStyle: const TextStyle(
                            color: Color(0xFFAEAEAE),
                            fontSize: fontSizeTextCalendar),
                        defaultTextStyle: TextStyle(
                            color: currentTheme.isDarkTheme
                                ? Colors.white
                                : Colors.black,
                            fontSize: fontSizeTextCalendar),
                        markerDecoration: BoxDecoration(
                            color: currentTheme.isDarkTheme
                                ? Colors.white
                                : const Color(0xFF263238),
                            shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: const Color(0xFF56BE64),
                            borderRadius: BorderRadius.circular(10)),
                        todayDecoration: BoxDecoration(
                          color: const Color.fromARGB(141, 86, 190, 100),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        holidayDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          shape: BoxShape.rectangle,
                        ),
                        holidayTextStyle: const TextStyle(
                            color: Colors.red, fontSize: fontSizeTextCalendar),
                      ),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: 'ru_RU',
                      firstDay: kFirstDay,
                      lastDay: kLastDay,
                      focusedDay: _focusedDay.value,
                      headerVisible: false,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      calendarFormat: _calendarFormat,
                      rangeSelectionMode: _rangeSelectionMode,
                      eventLoader: _getEventsForDay,
                      holidayPredicate: (day) {
                        if (day.weekday == DateTime.sunday ||
                            day.weekday == DateTime.saturday) {
                          return true;
                        }
                        return false;
                      },
                      onDaySelected: _onDaySelected,
                      onRangeSelected: _onRangeSelected,
                      onCalendarCreated: (controller) =>
                          _pageController = controller,
                      onPageChanged: (focusedDay) =>
                          _focusedDay.value = focusedDay,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() => _calendarFormat = format);
                        }
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final dayNow = DateTime.now();
                          final String text = day.day.toString();
                          if (day.isBefore(dayNow)) {
                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(
                                    fontSize: fontSizeTextCalendar,
                                    color: Colors.grey),
                              ),
                            );
                          }
                          return null;
                        },
                        dowBuilder: (context, day) {
                          if (day.weekday == DateTime.sunday ||
                              day.weekday == DateTime.saturday) {
                            final text = DateFormat.E('ru_RU').format(day);
                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: fontSizeTextCalendar),
                              ),
                            );
                          } else {
                            final text = DateFormat.E('ru_RU').format(day);
                            return Center(
                              child: Text(
                                text,
                                style: TextStyle(
                                    color: currentTheme.isDarkTheme
                                        ? Colors.white
                                        : const Color(0xFF263238),
                                    fontSize: fontSizeTextCalendar),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Expanded(
                      child: ValueListenableBuilder<List<Event>>(
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 350,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? const Color.fromARGB(255, 219, 215, 215)
                                      : const Color(0xFF56BE64),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Stack(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        bottom: 16.0,
                                        top: 24.0),
                                    child: ListTile(
                                      title: Text(
                                        '${value[index]}',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            const _AlertDialogEventInfo()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, top: 12.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '${DateFormat.MMMMd('ru_RU').format(value[index].date!)} ${value[index].time!.format(context)}',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ]),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Неизвестаня ошибка')),
          );
        }
      }),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;
  final void Function() changeTheme;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
    required this.changeTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM('ru_RU').format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            child: Text(
              '${headerText[0].toUpperCase()}${headerText.substring(1)}',
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          if (clearButtonVisible)
            IconButton(
              icon: const Icon(Icons.clear, size: sizeIcon),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          IconButton(
            icon: const Icon(Icons.brightness_4, size: sizeIcon),
            onPressed: () {
              changeTheme();
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: sizeIcon),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: sizeIcon),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}

class _AlertDialogAddEventWidget extends StatefulWidget {
  final List<Event> selectedEvents;
  final EventListViewBloc eventBloc;
  final void Function(
      {required DateTime? day,
      required Event event,
      required EventListViewBloc eventBloc}) addEvent;
  final DateTime? focusedDay;
  _AlertDialogAddEventWidget({
    Key? key,
    required this.selectedEvents,
    required this.addEvent,
    required this.focusedDay,
    required this.eventBloc,
  }) : super(key: key);

  @override
  State<_AlertDialogAddEventWidget> createState() =>
      _AlertDialogAddEventWidgetState();
}

class _AlertDialogAddEventWidgetState
    extends State<_AlertDialogAddEventWidget> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  Duration duration = const Duration(hours: 0, minutes: 0);
  TextEditingController controller = TextEditingController();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        width: 600,
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  String getTimeFromMins(int mins) {
    int hours = (mins ~/ 60);
    int minutes = mins % 60;
    return '$hours ч. $minutes м.';
  }

  bool isTimeOnRepeat(
      {required TimeOfDay time,
      required DateTime? focusedDay,
      required EventListViewBloc eventBloc}) {
    final listTime = eventBloc.state.meetingRoom.kEvents[focusedDay];

    for (var element in listTime as List<Event>) {
      if (element.time?.hour == time.hour &&
          element.time?.minute == time.minute) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    FocusNode _focusNode = FocusNode();
    final time = getTimeFromMins(duration.inMinutes);
    final TimeOfDay timeToFormat = TimeOfDay(
        hour: duration.inMinutes ~/ 60, minute: duration.inMinutes % 60);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  errorMessage != ''
                      ? Text(
                          errorMessage,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    focusNode: _focusNode,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Введите событие'),
                    controller: controller,
                    style: const TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Время события: $time',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 24),
                      ),
                      IconButton(
                          onPressed: () => _showDialog(
                                CupertinoTimerPicker(
                                  minuteInterval: 15,
                                  mode: CupertinoTimerPickerMode.hm,
                                  initialTimerDuration: duration,
                                  onTimerDurationChanged:
                                      (Duration newDuration) {
                                    setState(() => duration = newDuration);
                                  },
                                ),
                              ),
                          icon: const Icon(
                            CupertinoIcons.time_solid,
                            size: sizeIcon,
                            color: kPrimeyColorGreen,
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (controller.text.isEmpty) {
                            setState(() {
                              errorMessage = 'Пожалуйста, введите событие!';
                            });
                          } else {
                            final bool isDublicate = isTimeOnRepeat(
                              eventBloc: widget.eventBloc,
                              focusedDay: widget.focusedDay,
                              time: timeToFormat,
                            );

                            if (isDublicate) {
                              setState(() {
                                errorMessage =
                                    'Время занятно, выберите другое время';
                              });
                            } else {
                              _focusNode.unfocus();
                              final event = Event(
                                  title: controller.text,
                                  date: widget.focusedDay,
                                  time: timeToFormat);

                              widget.addEvent(
                                  day: widget.focusedDay,
                                  event: event,
                                  eventBloc: widget.eventBloc);

                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: const Text(
                          'Добавить',
                          style: TextStyle(color: Colors.black, fontSize: 24),
                        )),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertDialogEventInfo extends StatelessWidget {
  const _AlertDialogEventInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                  text: 'Где:\n\nКогда:',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
                child: ElevatedButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 24),
                    )))
          ],
        ),
      ),
    );
  }
}

class DropDownMenuMettingRooms extends StatefulWidget {
  final EventListViewBloc eventBloc;
  final ValueNotifier<List<Event>> selectedEventsWidget;
  final DateTime? selectedDayWidget;
  final List<Event> Function(DateTime? days) getEventsForDaysWidget;

  const DropDownMenuMettingRooms(
      {super.key,
      required this.eventBloc,
      required this.selectedEventsWidget,
      required this.selectedDayWidget,
      required this.getEventsForDaysWidget});
  @override
  _DropDownMenuMettingRoomsState createState() =>
      _DropDownMenuMettingRoomsState();
}

class _DropDownMenuMettingRoomsState extends State<DropDownMenuMettingRooms> {
  String? selectedRoom;

  @override
  Widget build(BuildContext context) {
    final eventBloc = context.watch<EventListViewBloc>();
    selectedRoom = eventBloc.state.meetingRoom.title;

    final meetingRoomsList = eventBloc.state.listNameRooms;

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFb3f2b2),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          iconSize: sizeIcon,
          borderRadius: BorderRadius.circular(10),
          hint: const Text('Выберите переговорную'),
          style: const TextStyle(fontSize: 30, color: Colors.black),
          value: selectedRoom,
          items: meetingRoomsList.map((String room) {
            return DropdownMenuItem(
              value: room,
              child: Row(
                children: [
                  Text(
                    room,
                  ),
                  selectedRoom == room
                      ? const Padding(
                          padding: EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 26,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedRoom = newValue;
            });
            eventBloc.add(EventChangeMeetingRoom(
              titileMettingRoom: newValue!,
              getEventsForDaysWidget: widget.getEventsForDaysWidget,
              selectedDayWidget: widget.selectedDayWidget,
              selectedEventsWidget: widget.selectedEventsWidget,
            ));
          },
        ),
      ),
    );
  }
}
