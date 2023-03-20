import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/utilities/utils.dart';

class AudioManager {
  final AudioPlayer audioPlayer;

  AudioManager({
    required this.audioPlayer,
  });
  
  double? totalDuration;
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
      var fadeInIntervalInMilis = (soundCue.easeIn.duration * 100).round();
      fadeIn = Timer.periodic(Duration(milliseconds: fadeInIntervalInMilis), (timer) async {
          var currentSecond = timer.tick * fadeInIntervalInMilis / 1000;
          var mappedValue = Utils.mapRange(currentSecond, 0, soundCue.easeIn.duration, 0, 1);

          await audioPlayer.setVolume(eval(mappedValue, soundCue.volume));
          
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

    var fadeOutIntervalInMilis = (soundCue.easeOut.duration * 100).round();
    fadeOut = Timer.periodic(Duration(milliseconds: fadeOutIntervalInMilis), (timer) async {
      var currentSecond = timer.tick * fadeOutIntervalInMilis / 1000;
      double mappedValue;

      if (endPremature) {
        prematureStart ??= currentSecond;
        mappedValue = 1 - Utils.mapRange(double.parse((currentSecond - prematureStart!).toStringAsFixed(2)), 0, soundCue.easeOut.duration, 0, 1);
      } else {
        if (totalDuration == null) {
          var duration = await audioPlayer.getDuration();
          if (duration != null) {
            totalDuration = duration.inMilliseconds / 1000.0;
          }
        }
        
        if (totalDuration == null) {
          return;
        }

        var fadeStart = totalDuration! - soundCue.easeOut.duration;
        
        if (currentSecond < fadeStart) {
          return;
        }

        mappedValue = 1 - Utils.mapRange(currentSecond, fadeStart, totalDuration!, 0, 1);
      }
      
      await audioPlayer.setVolume(eval(mappedValue, soundCue.volume));

      if (mappedValue <= 0) {
        await audioPlayer.stop();
        fadeOut!.cancel();
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
  
  double eval(double t, double volume) {
    return -volume * pow(t - 1, 2) + volume;
  }
}