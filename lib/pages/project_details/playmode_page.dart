import 'package:echocues/api/models/scene.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/pages/project_details/playmode_viewport.dart';
import 'package:flutter/material.dart';

class PlayModePageWidget extends StatelessWidget {
  final List<SceneModel> scenes;
  final List<SoundCue> soundCues;
  
  const PlayModePageWidget({Key? key, required this.scenes, required this.soundCues}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlaymodeViewport(
      scene: null, 
      scenes: scenes, 
      soundCues: soundCues,
    );
  }
}
