import 'package:conquest/presentation/views/profile/cards/activity_overview/character_session.dart';
import 'package:conquest/presentation/views/shared_widgets/app_calendar.dart';
import 'package:flutter/material.dart';

class CalendarSessionRow extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int sessions;

  const CalendarSessionRow({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.sessions,
  });

  @override
  State<CalendarSessionRow> createState() => _CalendarSessionRowState();
}

class _CalendarSessionRowState extends State<CalendarSessionRow> {
  final _calendarKey = GlobalKey();
  double? _measuredHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final box = _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final height = box.size.height;
    if (_measuredHeight != height) {
      setState(() => _measuredHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 4,
            child: KeyedSubtree(
              key: _calendarKey,
              child: AppCalendar(
                selectedDate: widget.selectedDate,
                onDateSelected: widget.onDateSelected,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: SizedBox(
              height: _measuredHeight ?? 260,
              child: CharacterSession(sessions: widget.sessions),
            ),
          ),
        ],
      ),
    );
  }
}