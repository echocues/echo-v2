import 'package:echocues/api/models/soundcue.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'labeled_widget.dart';

class VolumeTweaker extends StatefulWidget {
  final SoundCue soundCue;
  
  const VolumeTweaker({Key? key, required this.soundCue}) : super(key: key);

  @override
  State<VolumeTweaker> createState() => _VolumeTweakerState();
}

class _VolumeTweakerState extends State<VolumeTweaker> {
  @override
  Widget build(BuildContext context) {
    return LabeledWidget(
      label: "Volume: ",
      child: Row(
        children: [
          Text(
            widget.soundCue.volume.toStringAsFixed(1),
            style: GoogleFonts.notoSans(),
          ),
          Slider(
            value: widget.soundCue.volume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) => setState(() => widget.soundCue.volume = value),
          ),
        ],
      ),
    );
  }
}
