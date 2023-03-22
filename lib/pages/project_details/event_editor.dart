import 'package:echocues/api/models/event.dart';
import 'package:echocues/api/models/event_time.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/components/validated_text_field.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class EventEditor extends StatefulWidget {
  final List<SoundCue> soundCues;
  final List<EventModel> events;
  final VoidCallback onShouldRebuildTimeline;
  
  const EventEditor({Key? key, required this.soundCues, required this.onShouldRebuildTimeline, required this.events}) : super(key: key);

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
              child: Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: _EventTimeEditor(
                  eventTime: event!.time,
                  onShouldRebuildTimeline: widget.onShouldRebuildTimeline,
                ),
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
                          event!.cues.add(widget.soundCues.first.identifier);
                        });
                      },
                      icon: const Icon(Icons.add),
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
                    trailing: IconButton(
                      onPressed: () {
                        print("Add note");
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  body: Column(
                    children: [],
                  ),
                  isExpanded: notesExpanded,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    widget.events.remove(event!);
                    widget.onShouldRebuildTimeline();
                    setState(() {
                      event = null;
                    });
                  },
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
  final VoidCallback onShouldRebuildTimeline;
  
  const _EventTimeEditor({Key? key, required this.eventTime, required this.onShouldRebuildTimeline}) : super(key: key);

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
    return Row(
      children: [
        TextHelper.largeText(context, "Event Time"),
        Padding(
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
                      defaultValue: 0,
                      label: "Hours",
                      validator: (str) => int.tryParse(str),
                      onChanged: (val) {
                        widget.eventTime.hours = val;
                        widget.onShouldRebuildTimeline();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ValidatedTextField<int>(
                      value: widget.eventTime.minutes,
                      defaultValue: 0,
                      label: "Minutes",
                      validator: (str) => int.tryParse(str),
                        onChanged: (val) {
                          widget.eventTime.minutes = val;
                          widget.onShouldRebuildTimeline();
                        }
                    ),
                  ),
                ),
                Expanded(
                  child: ValidatedTextField<int>(
                    value: widget.eventTime.seconds,
                    defaultValue: 0,
                    label: "Seconds",
                    validator: (str) => int.tryParse(str),
                      onChanged: (val) {
                        widget.eventTime.seconds = val;
                        widget.onShouldRebuildTimeline();
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
    var allSoundCuesInProject = widget.cues.map((soundCue) => DropdownMenuItem<String>(
      // the actual value saved is the identifier, but displays the filename for ease of use
      value: soundCue.identifier,
      child: TextHelper.normal(context, soundCue.fileName),
    )).toList();
    
    return Column(
      children: widget.eventCues.map((eventCue) {
        return DropdownButton<String>(
          value: eventCue,
          items: allSoundCuesInProject,
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
