import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/models/event.dart';
import '../../api/models/scene.dart';

class ScenesPageWidget extends StatefulWidget {
  final List<SceneModel> scenes;

  const ScenesPageWidget({Key? key, required this.scenes}) : super(key: key);

  @override
  State<ScenesPageWidget> createState() => _ScenesPageWidgetState();
}

class _ScenesPageWidgetState extends State<ScenesPageWidget> {
  late List<ScenePanel> _events;

  _ScenesPageWidgetState();

  @override
  void initState() {
    super.initState();

    _events = [];
    for (SceneModel sceneModel in widget.scenes) {
      _events.add(ScenePanel(
        sceneName: sceneModel.name,
        events: sceneModel.events.map((e) => TimelineEventPanel(timelineEventModel: e)).toList(),
        isExpanded: false,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        expansionCallback: (index, expanded) {
          setState(() {
            _events[index].isExpanded = !expanded;
          });
        },
        children: _events.map((scene) {
          return ExpansionPanel(
            headerBuilder: (ctx, expanded) {
              return ListTile(
                title: Text(
                  scene.sceneName,
                  style: GoogleFonts.notoSans(),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: ExpansionPanelList(
                expansionCallback: (index, expanded) {
                  setState(() {
                    scene.events[index].isExpanded = !expanded;
                  });
                },
                children: scene.events.map((event) {
                  return ExpansionPanel(
                    headerBuilder: (ctx, expanded) {
                      return ListTile(
                        title: Text(event.timelineEventModel.time.toString()),
                      );
                    },
                    // this should be the notes and the cues
                    body: const Placeholder(),
                    isExpanded: event.isExpanded,
                  );
                }).toList(),
              ),
            ),
            isExpanded: scene.isExpanded,
          );
        }).toList(),
      ),
    );
  }
}

class ScenePanel {
  String sceneName;
  List<TimelineEventPanel> events;
  bool isExpanded;

  ScenePanel({
    required this.sceneName,
    required this.events,
    required this.isExpanded,
  });
}

class TimelineEventPanel {
  EventModel timelineEventModel;
  bool isExpanded;
  
  TimelineEventPanel({
    required this.timelineEventModel,
    this.isExpanded = false,
  });
}