import 'package:echocues/components/soundcue_button.dart';
import 'package:flutter/material.dart';

class SoundCuesPageWidget extends StatelessWidget {
  const SoundCuesPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: SoundCueButton());
  }
}
