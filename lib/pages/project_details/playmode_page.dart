import 'package:echocues/api/models/scene.dart';
import 'package:echocues/pages/project_details/playmode_viewport.dart';
import 'package:flutter/material.dart';

class PlayModePageWidget extends StatelessWidget {
  const PlayModePageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaymodeViewport(scene: SceneModel(
      name: "Scene 1",
      events: []
    ),);
  }
}
