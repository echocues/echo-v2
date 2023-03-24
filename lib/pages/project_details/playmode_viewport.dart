import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/scene.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/api/server_caller.dart';
import 'package:echocues/utilities/audio_manager.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PlaymodeViewport extends StatelessWidget {
  final SceneModel? scene;
  
  const PlaymodeViewport({Key? key, this.scene}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scene == null) {
      return Center(
        child: TextHelper.title(context, "No Scene Selected"),
      );
    }
    
    return Container();
  }
}

class _PlayCueButton extends StatefulWidget {
  final SoundCue soundCue;
  
  const _PlayCueButton({Key? key, required this.soundCue}) : super(key: key);

  @override
  State<_PlayCueButton> createState() => _PlayCueButtonState();
}

class _PlayCueButtonState extends State<_PlayCueButton> {
  late AudioManager _audioPlayer;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager(
      audioPlayer: AudioPlayer(playerId: const Uuid().v4()),
    );
  }


  @override
  void dispose() async {
    super.dispose();
    await _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (widget.soundCue.fileName == "Unset Sound File") {
              return;
            }

            if (_audioPlayer.audioPlayer.state == PlayerState.playing) {
              await _audioPlayer.stop();
              setState(() {
                playing = false;
              });
              return;
            }

            var instance = await SharedPreferences.getInstance();
            var projectId = instance.getString("editingProject");

            await _audioPlayer.start(
                ServerCaller.audioSource(projectId!, widget.soundCue.fileName),
                widget.soundCue,
                onComplete: () {
                  setState(() => playing = false);
                }
            );

            setState(() {
              playing = true;
            });
          },
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
        ),
        TextHelper.normal(context, widget.soundCue.fileName)
      ],
    );
  }
}
