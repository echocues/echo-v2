import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/components/labeled_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaybackRateTweaker extends StatefulWidget {
  final SoundCue soundCue;
  
  const PlaybackRateTweaker({Key? key, required this.soundCue}) : super(key: key);

  @override
  State<PlaybackRateTweaker> createState() => _PlaybackRateTweakerState();
}

class _PlaybackRateTweakerState extends State<PlaybackRateTweaker> {
  @override
  Widget build(BuildContext context) {
    return LabeledWidget(
      label: "Speed: ",
      child: Row(
        children: [
          Text(
            widget.soundCue.speed.toStringAsFixed(1),
            style: GoogleFonts.notoSans(),
          ),
          Slider(
            value: widget.soundCue.speed,
            min: 0.1,
            max: 2.0,
            onChanged: (value) => setState(() => widget.soundCue.speed = value),
          ),
        ],
      ),
    );
  }
}
