import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/soundcue_model.dart';
import 'package:echocues/components/labeled_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockholm/stockholm.dart';

class SoundCuesPageWidget extends StatefulWidget {
  final List<SoundCue> _soundCuesData;

  const SoundCuesPageWidget({Key? key, required List<SoundCue> soundCuesData})
      : _soundCuesData = soundCuesData,
        super(key: key);

  @override
  State<SoundCuesPageWidget> createState() => _SoundCuesPageWidgetState(soundCuesData: _soundCuesData);
}

class _SoundCuesPageWidgetState extends State<SoundCuesPageWidget> {
  late List<SoundCuePanel> _soundCues;
  late AudioPlayer _audioPlayer;
  
  final List<SoundCue> _soundCuesData;

  _SoundCuesPageWidgetState({required List<SoundCue> soundCuesData})
      : _soundCuesData = soundCuesData;

  @override
  void initState() {
    super.initState();
    _soundCues = _soundCuesData
        .map((e) => SoundCuePanel(soundCue: e, isExpanded: false))
        .toList();
    _audioPlayer = AudioPlayer(playerId: "Preview Player");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
                      Text("Create Sound Cue", style: GoogleFonts.notoSans(),),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _soundCues.add(SoundCuePanel(
                        isExpanded: false,
                        soundCue: SoundCue(
                          name: "New Sound Cue",
                          file: "",
                          easeIn: false,
                          easeOut: false,
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
                        onPressed: () {
                          // todo play audio
                        },
                      ),
                      title: Text(
                        e.soundCue.name!,
                        style: GoogleFonts.notoSans(),
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
                                      "Sound File: \"${e.soundCue.file!}\"",
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
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio,);
                                      if (result != null) {
                                        PlatformFile file = result.files.single;
                                        Uint8List? data = file.bytes;
                                        if (data == null) return;
                                        // todo upload data to server
                                        setState(() {
                                          e.soundCue.file = file.name;
                                          e.soundCue.name = file.name;
                                        });
                                      }
                                    }
                                  ),
                                ],
                              ),
                              LabeledWidget(
                                label: "Ease In",
                                child: Switch(
                                  value: e.soundCue.easeIn!,
                                  onChanged: (value) {
                                    setState(() {
                                      e.soundCue.easeIn = !e.soundCue.easeIn!;
                                    });
                                  },
                                ),
                              ),
                              LabeledWidget(
                                label: "Ease Out",
                                child: Switch(
                                  value: e.soundCue.easeOut!,
                                  onChanged: (value) {
                                    setState(() {
                                      e.soundCue.easeOut = !e.soundCue.easeOut!;
                                    });
                                  },
                                ),
                              ),
                              LabeledWidget(
                                label: "Volume: ", 
                                child: Row(
                                  children: [
                                    Text(
                                      e.soundCue.volume!.toStringAsFixed(1),
                                      style: GoogleFonts.notoSans(),
                                    ),
                                    Slider(
                                      value: e.soundCue.volume!,
                                      min: 0.0,
                                      max: 1.0,
                                      onChanged: (value) {
                                        setState(() => e.soundCue.volume = value);
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
