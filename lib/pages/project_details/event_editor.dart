import 'package:echocues/api/models/event.dart';
import 'package:echocues/api/models/event_time.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/components/labeled_widget.dart';
import 'package:echocues/components/validated_text_field.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class EventEditor extends StatefulWidget {
  final List<SoundCue> soundCues;
  
  const EventEditor({Key? key, required this.soundCues}) : super(key: key);

  @override
  State<EventEditor> createState() => EventEditorState();
}

class EventEditorState extends State<EventEditor> {
  EventModel? event;
  bool notesExpanded = false;
  bool cuesExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: TextHelper.title(context, "No Event Selected"),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextHelper.title(context, "Event"),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _EventTimeEditor(
                eventTime: event!.time,
              ),
            ),
            ExpansionPanelList(
              expansionCallback: (index, expanded) {
                setState(() {
                  if (index == 0) {
                    cuesExpanded = !cuesExpanded;
                  } else {
                    notesExpanded = !notesExpanded;
                  }
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (ctx, expanded) => ListTile(
                    title: TextHelper.largeText(ctx, "Sound Cues"),
                    trailing: IconButton(
                      onPressed: () { 
                        setState(() {
                          event!.cues.add("");
                        });
                      },
                      icon: const Icon(Icons.add_circle_rounded),
                    ),
                  ),
                  body: _EventSoundCuesEditor(
                    eventCues: event!.cues,
                    cues: widget.soundCues,
                  ),
                  isExpanded: cuesExpanded,
                ),
                ExpansionPanel(
                  headerBuilder: (ctx, expanded) => ListTile(
                    title: TextHelper.largeText(ctx, "Notes"),
                  ),
                  body: Column(
                    children: [
                      
                    ],
                  ),
                  isExpanded: notesExpanded,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: TextHelper.normal(context, "Delete Event"),
                ),
              ),
            ),
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

class _EventSoundCuesEditor extends StatefulWidget {
  final List<String> eventCues;
  final List<SoundCue> cues;
  
  const _EventSoundCuesEditor({Key? key, required this.eventCues, required this.cues}) : super(key: key);

  @override
  State<_EventSoundCuesEditor> createState() => _EventSoundCuesEditorState();
}

class _EventSoundCuesEditorState extends State<_EventSoundCuesEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.eventCues.map((eventCue) {
        return DropdownButton<String>(
          value: eventCue,
          items: widget.cues.map((soundCue) => DropdownMenuItem(
            value: soundCue.fileName,
            child: TextHelper.normal(context, soundCue.fileName),
          )).toList(),
          onChanged: (val) {
            setState(() {
              widget.eventCues[widget.eventCues.indexOf(eventCue)] = val!;
            });
          },
          hint: TextHelper.normal(context, "Select Sound Cue"),
        );
      }).toList(),
    );
  }
}
