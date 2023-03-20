import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/ease_settings.dart';
import 'package:echocues/api/server_caller.dart';
import 'package:echocues/components/ease_setting_tweaker.dart';
import 'package:echocues/components/volume_tweaker.dart';
import 'package:echocues/utilities/audio_manager.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../../api/models/soundcue.dart';

class SoundCuesPageWidget extends StatefulWidget {
  final List<SoundCue> soundCuesData;

  const SoundCuesPageWidget({Key? key, required this.soundCuesData})
      : super(key: key);

  @override
  State<SoundCuesPageWidget> createState() => _SoundCuesPageWidgetState();
}

class _SoundCuesPageWidgetState extends State<SoundCuesPageWidget> {

  _SoundCuesPageWidgetState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.soundCuesData.isEmpty ? Center(child: TextHelper.normal(context, "No available sound cues. Create one with the button on the bottom right")) : SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            children: widget.soundCuesData.map<Widget>((soundCue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SoundCueButton(
                  soundCue: soundCue,
                  soundCues: widget.soundCuesData,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.soundCuesData.add(SoundCue(
              identifier: const Uuid().v4(),
              fileName: "Unset Sound File",
              easeIn: EaseSettings(enabled: false, duration: 1),
              easeOut: EaseSettings(enabled: false, duration: 1),
              volume: 1.0,
            ));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SoundCueButton extends StatefulWidget {
  final SoundCue soundCue;
  final List<SoundCue> soundCues;
  
  const SoundCueButton({Key? key, required this.soundCue, required this.soundCues}) : super(key: key);

  @override
  State<SoundCueButton> createState() => _SoundCueButtonState();
}

class _SoundCueButtonState extends State<SoundCueButton> {
  late AudioManager _audioPlayer;
  bool playing = false;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager(
      audioPlayer: AudioPlayer(playerId: "Preview Player"),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _audioPlayer.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Theme.of(context).colorScheme.background.withAlpha(120),
      collapsedBackgroundColor: Theme.of(context).colorScheme.background.withAlpha(80),
      childrenPadding: const EdgeInsets.only(left: 70, bottom: 12.0, top: 12.0),
      title: ListTile(
        leading: IconButton(
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
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
            );
            
            setState(() {
              playing = true;
            });
          },
        ),
        title: TextHelper.largeText(context, path.basenameWithoutExtension(widget.soundCue.fileName)),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              widget.soundCues.removeWhere((element) => element == widget.soundCue);
            });
          },
          icon: const Icon(Icons.delete),
        ),
      ),
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "Sound File: \"${widget.soundCue.fileName}\"",
                style: GoogleFonts.notoSans(),
              ),
            ),
            TextButton(
                child: Text(
                  "Select Sound File",
                  style: GoogleFonts.notoSans(),
                ),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio,);
                  if (result != null) {
                    PlatformFile file = result.files.single;
                    Uint8List? data = file.bytes;
                    if (data == null) return;
                    var instance = await SharedPreferences.getInstance();
                    var projectId = instance.getString("editingProject");
                    // TODO because this setState does not rebuild SoundCuePage the expansion tile does not
                    // get rebuilt so the title does not change properly 
                    await ServerCaller.uploadAudio(projectId!, file.name, data)
                        .whenComplete(() => setState(() => widget.soundCue.fileName = file.name));
                  }
                }),
          ],
        ),
        EaseSettingsTweaker(
          settings: widget.soundCue.easeIn,
          label: "Ease In",
        ),
        EaseSettingsTweaker(
          settings: widget.soundCue.easeOut,
          label: "Ease Out",
        ),
        VolumeTweaker(soundCue: widget.soundCue,),
      ],
    );
  }
}
