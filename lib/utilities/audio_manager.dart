import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/utilities/utils.dart';

class AudioManager {
  final AudioPlayer audioPlayer;

  AudioManager({
    required this.audioPlayer,
  });
  
  late double totalDuration;
  bool endPremature = false;
  double? prematureStart;
  Timer? fadeIn;
  Timer? fadeOut;

  Future<void> dispose() async {
    await audioPlayer.dispose();
    
    if (fadeIn != null) {
      fadeIn!.cancel();
      fadeIn = null;
    }
    
    if (fadeOut != null) {
      fadeOut!.cancel();
      fadeOut = null;
    }
  }
  
  Future<void> start(Source source, SoundCue soundCue, {Duration? position}) async {
    await audioPlayer.play(
      source,
      volume: 0,
      position: position,
    );
    
    if (!soundCue.easeIn.enabled) {
      await audioPlayer.setVolume(soundCue.volume);
    } else {
      fadeIn = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
          var currentSecond = timer.tick * 0.1;
          var mappedValue = Utils.mapRange(currentSecond, 0, soundCue.easeIn.duration, 0, 1);

          await audioPlayer.setVolume(eval(mappedValue));
          
          if (mappedValue == 1) {
            if (fadeIn == null) return;
            fadeIn!.cancel();
            fadeIn = null;
          }
        });
    }
    
    if (!soundCue.easeOut.enabled) {
      return;
    }

    totalDuration = (await audioPlayer.getDuration())!.inMilliseconds / 1000.0;
    fadeOut = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      var currentSecond = timer.tick * 0.1;
      double mappedValue;

      if (endPremature) {
        prematureStart ??= currentSecond;
        mappedValue = 1 - Utils.mapRange(currentSecond - prematureStart!, 0, soundCue.easeOut.duration, 0, 1);
      } else {
        var fadeStart = totalDuration - soundCue.easeOut.duration;
        if (currentSecond < fadeStart) {
          return;
        }

        mappedValue = 1 - Utils.mapRange(currentSecond, fadeStart, totalDuration, 0, 1);
      }

      if (mappedValue < 0) {
        // not time to fade yet
        return;
      }

      await audioPlayer.setVolume(eval(mappedValue));

      if (mappedValue == 0) {
        if (fadeOut == null) return;
        fadeOut!.cancel();
        fadeOut = null;
        audioPlayer.stop();
        cleanup();
      }
    });
  }
  
  Future<void> stop() async {
    if (fadeOut == null) {
      audioPlayer.stop();
      cleanup();
      return;
    }
    
    endPremature = true;
  }
  
  void cleanup() {
    endPremature = false;
    prematureStart = null;
    fadeIn = null;
    fadeOut = null;
  }
  
  double eval(double t) {
    return t;
  }
}