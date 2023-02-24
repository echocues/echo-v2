import 'package:flutter/material.dart';

class SoundCueButton extends StatefulWidget {
  const SoundCueButton({Key? key}) : super(key: key);

  @override
  State<SoundCueButton> createState() => _SoundCueButtonState();
}

class _SoundCueButtonState extends State<SoundCueButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 60,
      child: const ExpansionTile(
        title: Text("Test"),
      )
    );
  }
}
