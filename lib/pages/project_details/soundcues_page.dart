import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/ease_settings.dart';
import 'package:echocues/api/server_caller.dart';
import 'package:echocues/components/ease_setting_tweaker.dart';
import 'package:echocues/components/labeled_widget.dart';
import 'package:echocues/utilities/audio_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockholm/stockholm.dart';
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
  late List<SoundCuePanel> _soundCues;
  late AudioManager _audioPlayer;

  _SoundCuesPageWidgetState();

  @override
  void initState() {
    super.initState();
    _soundCues = widget.soundCuesData
        .map((e) => SoundCuePanel(soundCue: e, isExpanded: false))
        .toList();
    _audioPlayer = AudioManager(
      audioPlayer: AudioPlayer(playerId: "Preview Player"),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _audioPlayer.dispose();
    widget.soundCuesData.clear();
    widget.soundCuesData.addAll(_soundCues.map((e) => e.soundCue));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              height: 40,
              child: FittedBox(
                fit: BoxFit.fill,
                child: StockholmButton(
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.add),
                      ),
                      Text(
                        "Create Sound Cue",
                        style: GoogleFonts.notoSans(),
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _soundCues.add(SoundCuePanel(
                        isExpanded: false,
                        soundCue: SoundCue(
                          identifier: const Uuid().v4(),
                          fileName: "Unset Sound File",
                          easeIn: EaseSettings(enabled: false, duration: 1),
                          easeOut: EaseSettings(enabled: false, duration: 1),
                          volume: 1.0,
                        ),
                      ));
                    });
                  },
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: ExpansionPanelList(
              expansionCallback: (index, expanded) {
                setState(() {
                  _soundCues[index].isExpanded = !expanded;
                });
              },
              children: _soundCues.map<ExpansionPanel>((e) {
                return ExpansionPanel(
                  headerBuilder: (ctx, expanded) {
                    return ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          if (_audioPlayer.audioPlayer.state == PlayerState.playing) {
                            await _audioPlayer.stop();
                            return;
                          }

                          var instance = await SharedPreferences.getInstance();
                          var projectId = instance.getString("editingProject");

                          await _audioPlayer.start(
                            ServerCaller.audioSource(projectId!, e.soundCue.fileName),
                            e.soundCue,
                          );
                        },
                      ),
                      title: Text(
                        path.basenameWithoutExtension(e.soundCue.fileName),
                        style: GoogleFonts.notoSans(),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _soundCues.removeWhere((element) => element == e);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.only(left: 70.0),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      "Sound File: \"${e.soundCue.fileName}\"",
                                      style: GoogleFonts.notoSans(),
                                    ),
                                  ),
                                  StockholmButton(
                                      child: Text(
                                        "Select Sound File",
                                        style: GoogleFonts.notoSans(),
                                      ),
                                      onPressed: () async {
                                        // does not work?
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.audio,
                                        );
                                        if (result != null) {
                                          PlatformFile file =
                                              result.files.single;
                                          Uint8List? data = file.bytes;
                                          if (data == null) return;
                                          var instance = await SharedPreferences
                                              .getInstance();
                                          var projectId = instance
                                              .getString("editingProject");
                                          await ServerCaller.uploadAudio(
                                                  projectId!, file.name, data)
                                              .whenComplete(() => setState(() {
                                                    e.soundCue.fileName =
                                                        file.name;
                                                  }));
                                        }
                                      }),
                                ],
                              ),
                              EaseSettingsTweaker(
                                  settings: e.soundCue.easeIn,
                                  setEaseFunction: (f) => setState(f()),
                                  label: "Ease In"),
                              EaseSettingsTweaker(
                                  settings: e.soundCue.easeOut,
                                  setEaseFunction: (f) => setState(f()),
                                  label: "Ease Out"),
                              LabeledWidget(
                                label: "Volume: ",
                                child: Row(
                                  children: [
                                    Text(
                                      e.soundCue.volume.toStringAsFixed(1),
                                      style: GoogleFonts.notoSans(),
                                    ),
                                    Slider(
                                      value: e.soundCue.volume,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (value) {
                                        setState(
                                            () => e.soundCue.volume = value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  isExpanded: e.isExpanded,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SoundCuePanel {
  SoundCue soundCue;
  bool isExpanded;

  SoundCuePanel({required this.soundCue, required this.isExpanded});
}
