import 'package:echocues/api/models/event.dart';
import 'package:echocues/api/models/event_time.dart';
import 'package:echocues/components/float_text_field.dart';
import 'package:echocues/components/labeled_widget.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class EventEditor extends StatefulWidget {
  final EventModel? event;

  const EventEditor({Key? key, required this.event}) : super(key: key);

  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  @override
  Widget build(BuildContext context) {
    if (widget.event == null) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: TextHelper.normal(context, "No Event Selected"),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextHelper.title(context, "Event"),
            ),
            _EventTimeEditor(
              eventTime: widget.event!.time,
            )
          ],
        ),
      ),
    );
  }
}

class _EventTimeEditor extends StatefulWidget {
  final EventTime eventTime;

  const _EventTimeEditor({Key? key, required this.eventTime}) : super(key: key);

  @override
  State<_EventTimeEditor> createState() => _EventTimeEditorState();
}

class _EventTimeEditorState extends State<_EventTimeEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledWidget(
      label: "Event Time",
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SizedBox(
          width: 220,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ValidatedTextField<int>(
                    value: widget.eventTime.hours,
                    label: "Hours",
                    validator: (str) => int.tryParse(str),
                    onChanged: (val) => widget.eventTime.hours = val,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ValidatedTextField<int>(
                    value: widget.eventTime.minutes,
                    label: "Minutes",
                    validator: (str) => int.tryParse(str),
                    onChanged: (val) => widget.eventTime.minutes = val,
                  ),
                ),
              ),
              Expanded(
                child: ValidatedTextField<int>(
                  value: widget.eventTime.seconds,
                  label: "Seconds",
                  validator: (str) => int.tryParse(str),
                  onChanged: (val) => widget.eventTime.seconds = val,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
