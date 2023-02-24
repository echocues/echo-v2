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
  final List<SoundCue> _soundCuesData;

  _SoundCuesPageWidgetState({required List<SoundCue> soundCuesData})
      : _soundCuesData = soundCuesData;

  @override
  void initState() {
    super.initState();
    _soundCues = _soundCuesData
        .map((e) => SoundCuePanel(soundCue: e, isExpanded: false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    onPressed: () {},
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
                              StockholmButton(
                                child: Text(
                                  "Select Sound File",
                                  style: GoogleFonts.notoSans(),
                                ),
                                onPressed: () async {
                                  // does not work?
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio,);
                                  if (result != null) {
                                    // e.soundCue.file = result.files.single.path;
                                    print(result.files.single.path);
                                  }
                                }
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  e.soundCue.file!,
                                  style: GoogleFonts.notoSans(),
                                ),
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
    );
  }
}

class SoundCuePanel {
  SoundCue soundCue;
  bool isExpanded;

  SoundCuePanel({required this.soundCue, required this.isExpanded});
}
