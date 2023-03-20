import 'package:echocues/api/models/event.dart';
import 'package:echocues/pages/project_details/event_editor.dart';
import 'package:echocues/pages/project_details/playmode_viewport.dart';
import 'package:echocues/pages/project_details/scene_dropdown.dart';
import 'package:echocues/pages/project_details/timeline_editor.dart';
import 'package:flutter/material.dart';
import '../../api/models/scene.dart';

class ScenesPageWidget extends StatefulWidget {
  final List<SceneModel> scenes;

  const ScenesPageWidget({Key? key, required this.scenes}) : super(key: key);

  @override
  State<ScenesPageWidget> createState() => _ScenesPageWidgetState();
}

class _ScenesPageWidgetState extends State<ScenesPageWidget> {
  
  SceneModel? _editingScene;
  EventModel? _editingEvent;

  _ScenesPageWidgetState();

  @override
  void initState() {
    super.initState();
    _editingScene = widget.scenes.isNotEmpty ? widget.scenes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: EventEditor(
                      event: _editingEvent,
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: PlaymodeViewport(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SceneDropdown(
                    scenes: widget.scenes,
                    initialEditingModel: _editingScene,
                    sceneChanged: (newScene) {
                      setState(() {
                        _editingScene = newScene;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TimelineEditor(
                    events: _editingScene?.events,
                    onEditEvent: (event) {
                      setState(() {
                        _editingEvent = event;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
