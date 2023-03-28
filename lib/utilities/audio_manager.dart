import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/utilities/utils.dart';

class AudioManager {
  late AudioPlayer audioPlayer;
  
  AudioManager() {
    audioPlayer = AudioPlayer();
  }

  double? _totalDuration;
  bool _endPremature = false;
  double? _prematureStart;
  Timer? _fadeIn;
  Timer? _fadeOut;
  StreamSubscription<void>? _onCompleteCallback;

  Future<void> preload(Source source) async {
    await audioPlayer.setSource(source);
  }
  
  Future<void> dispose() async {
    await audioPlayer.dispose();

    if (_fadeIn != null) {
      _fadeIn!.cancel();
      _fadeIn = null;
    }

    if (_fadeOut != null) {
      _fadeOut!.cancel();
      _fadeOut = null;
    }
  }

  Future<void> start(Source? source, SoundCue soundCue, {Duration? position, VoidCallback? onComplete}) async {
    if (source != null) {
      if (audioPlayer.source == null || audioPlayer.source != source) {
        await audioPlayer.setSource(source);
      }
    }
    
    await audioPlayer.setPlaybackRate(soundCue.speed);
    await audioPlayer.setVolume(0);
    await audioPlayer.seek(position ?? Duration.zero);
    await audioPlayer.resume();

    if (!soundCue.easeIn.enabled) {
      await audioPlayer.setVolume(soundCue.volume);
    } else {
      var fadeInIntervalInMilis = (soundCue.easeIn.duration * 50).round();
      _fadeIn = Timer.periodic(Duration(milliseconds: fadeInIntervalInMilis), (timer) async {
        var currentSecond = timer.tick * fadeInIntervalInMilis / 1000;
        var mappedValue = Utils.mapRange(currentSecond, 0, soundCue.easeIn.duration, 0, 1);

        await audioPlayer.setVolume(_eval(mappedValue, soundCue.volume));

        if (mappedValue == 1) {
          if (_fadeIn == null) return;
          _fadeIn!.cancel();
          _fadeIn = null;
        }
      });
    }

    if (!soundCue.easeOut.enabled) {
      if (onComplete != null) {
        _onCompleteCallback = audioPlayer.onPlayerComplete.listen((_) => _cleanup(onComplete));
      }
      return;
    }

    var fadeOutIntervalInMilis = (soundCue.easeOut.duration * 50).round();
    _fadeOut = Timer.periodic(Duration(milliseconds: fadeOutIntervalInMilis), (timer) async {
      var currentSecond = timer.tick * fadeOutIntervalInMilis / 1000;
      double mappedValue;

      if (_endPremature) {
        _prematureStart ??= currentSecond;
        mappedValue = 1 - Utils.mapRange(double.parse((currentSecond - _prematureStart!).toStringAsFixed(2)), 0, soundCue.easeOut.duration, 0, 1);
      } else {
        if (_totalDuration == null) {
          var duration = await audioPlayer.getDuration();
          if (duration != null && duration.inMilliseconds != 0) {
            _totalDuration = duration.inMilliseconds / 1000.0;
          }
        }

        if (_totalDuration == null) {
          return;
        }

        var fadeStart = _totalDuration! - soundCue.easeOut.duration;

        if (currentSecond < fadeStart) {
          return;
        }

        mappedValue = 1 - Utils.mapRange(currentSecond, fadeStart, _totalDuration!, 0, 1);
      }

      await audioPlayer.setVolume(_eval(mappedValue, soundCue.volume));

      if (mappedValue <= 0) {
        await audioPlayer.pause();
        _fadeOut!.cancel();
        _cleanup(onComplete);
      }
    });
  }

  Future<void> stop({VoidCallback? onComplete}) async {
    if (_fadeOut == null) {
      audioPlayer.pause();
      _cleanup(onComplete);
      return;
    }

    _endPremature = true;
  }

  void _cleanup(VoidCallback? onComplete) {
    _endPremature = false;
    _prematureStart = null;
    _fadeIn = null;
    _fadeOut = null;
    _totalDuration = null;
    _onCompleteCallback?.cancel();
    _onCompleteCallback = null;

    if (onComplete != null) {
      onComplete();
    }
  }

  double _eval(double t, double volume) {
    return volume * pow(t , 2);
  }
}