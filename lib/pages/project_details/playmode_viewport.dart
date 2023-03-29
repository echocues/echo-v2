import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:echocues/api/models/event.dart';
import 'package:echocues/api/models/scene.dart';
import 'package:echocues/api/models/soundcue.dart';
import 'package:echocues/api/server_caller.dart';
import 'package:echocues/utilities/audio_manager.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaymodeViewport extends StatefulWidget {
  final SceneModel? scene;
  final List<SceneModel> scenes;
  final List<SoundCue> soundCues;

  const PlaymodeViewport(
      {Key? key, this.scene, required this.scenes, required this.soundCues})
      : super(key: key);

  @override
  State<PlaymodeViewport> createState() => _PlaymodeViewportState();
}

class _PlaymodeViewportState extends State<PlaymodeViewport> {

  SceneModel? _editingScene;
  Stopwatch? _timeRunner;
  Timer? _timeWatcher;
  late List<_EventWrapper> eventsShown;
  late String projectId;

  @override
  void initState() {
    super.initState();
    _editingScene = widget.scene;
    eventsShown = [];
    assignProjectId();
  }
  
  void assignProjectId() async {
    var instance = await SharedPreferences.getInstance();
    projectId = instance.getString("editingProject")!;
  }

  @override
  Widget build(BuildContext context) {
    if (_editingScene != null) {
      if (!widget.scenes.contains(_editingScene)) {
        _editingScene = null;
      }
    }
    
    if (_editingScene == null) {
      return Stack(
        children: [
          Center(
            child: TextHelper.title(context, "No Scene Selected"),
          ),
          _newPlaybackControl(),
        ],
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: eventsShown.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Ink(
                  decoration: BoxDecoration(
                    color: event.notified ? 
                            Theme.of(context).colorScheme.secondary : 
                            Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.event.cues.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextHelper.largeText(context, "Cues"),
                              ),
                              ...event.event.cues.map((e) => _PlayCueButton(projectId: projectId, soundCue: widget.soundCues.firstWhere((element) => element.identifier == e))),
                            
                            if (event.event.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextHelper.largeText(context, "Notes"),
                              ),
                              ...event.event.notes.map((e) => Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: TextHelper.normal(context, "\u2022  $e"),
                              )),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => setState(() => eventsShown.remove(event)),
                            icon: const Icon(Icons.delete),
                            splashRadius: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _newPlaybackControl(),
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  Widget _newPlaybackControl() {
    return _PlayModeControls(
      scenes: widget.scenes,
      onSelectScene: (scene) {
        setState(() {
          _editingScene = scene;
        });
      },
      onReset: () {
        setState(() {
          eventsShown.clear();

          _timeWatcher?.cancel();
          _timeWatcher = null;

          _timeRunner?.stop();
          _timeRunner = null;
        });
      },
      onStart: () {
        var sortedEvents = List.of(_editingScene!.events);
        sortedEvents.sort((a, b) => a.time.toSeconds().compareTo(b.time.toSeconds()));

        for (var event in sortedEvents) {
            if (eventsShown.any((e) => e.event == event)) continue;
            eventsShown.add(_EventWrapper(event, false));
        }

        setState(() {
          _timeRunner ??= Stopwatch();
          _timeRunner!.start();
         
          for (var event in eventsShown.where((element) => element.event.time.toSeconds() == 0)) {
            event.notified = true;
          }

          _timeWatcher = Timer.periodic(const Duration(seconds: 1), (timer) {
            var change = false;
            
            for (var event in eventsShown.where((element) => element.event.time.toSeconds() == _timeRunner!.elapsed.inSeconds)) {
                event.notified = true;
                change = true;
            }

            if (!change) return;
            setState(() {});
          });
        });
      },
      onPause: () {
        setState(() {
          _timeRunner?.stop();
          _timeWatcher?.cancel();
          _timeWatcher = null;
        });
      },
      currentScene: _editingScene,
      isPlaying: _timeWatcher == null ? false : _timeWatcher!.isActive, 
      timeString: _timeRunner != null ? _printDuration(_timeRunner!.elapsed) : "00:00:00",
    );
  }
}

class _EventWrapper {
    final EventModel event;
    bool notified;

    _EventWrapper(this.event, this.notified);
}

class _PlayModeControls extends StatelessWidget {

  final SceneModel? currentScene;
  final List<SceneModel> scenes;
  final VoidCallback onReset;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final Function(SceneModel) onSelectScene;
  final bool isPlaying;
  final String timeString;

  const _PlayModeControls({Key? key,
    required this.scenes,
    required this.onReset,
    required this.onSelectScene,
    required this.onStart,
    required this.currentScene,
    required this.isPlaying,
    required this.onPause, 
    required this.timeString,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextHelper.normal(context, "Time: $timeString"),
                _SelectSceneDropdown(
                  scenes: scenes,
                  onChanged: onSelectScene,
                  currentScene: currentScene,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: currentScene == null ? null : (!isPlaying ? onStart : onPause),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(!isPlaying ? Icons.start : Icons.pause),
                          TextHelper.normal(context, !isPlaying ? "Start" : "Pause"),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: currentScene == null ? null : onReset,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh),
                          TextHelper.normal(context, "Reset"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayCueButton extends StatefulWidget {
  final SoundCue soundCue;
  final String projectId;

  const _PlayCueButton({Key? key, required this.soundCue, required this.projectId}) : super(key: key);

  @override
  State<_PlayCueButton> createState() => _PlayCueButtonState();
}

class _PlayCueButtonState extends State<_PlayCueButton> {
  late AudioManager _audioPlayer;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager();
    _audioPlayer.preload(ServerCaller.audioSource(widget.projectId, widget.soundCue.fileName));
  }

  @override
  void dispose() async {
    super.dispose();
    await _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (widget.soundCue.fileName == "Unset Sound File") {
              return;
            }

            if (_audioPlayer.audioPlayer.state == PlayerState.playing) {
              await _audioPlayer.stop();
              setState(() {
                playing = false;
              });
              return;
            }
            
            await _audioPlayer.start(ServerCaller.audioSource(widget.projectId, widget.soundCue.fileName), widget.soundCue, onComplete: () {
              setState(() => playing = false);
            });

            setState(() {
              playing = true;
            });
          },
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          splashRadius: 24,
        ),
        TextHelper.normal(context, widget.soundCue.fileName),
      ],
    );
  }
}

class _SelectSceneDropdown extends StatefulWidget {
  final List<SceneModel> scenes;
  final Function(SceneModel) onChanged;
  final SceneModel? currentScene;

  const _SelectSceneDropdown({Key? key,
    required this.scenes,
    required this.onChanged,
    required this.currentScene})
      : super(key: key);

  @override
  State<_SelectSceneDropdown> createState() => _SelectSceneDropdownState();
}

class _SelectSceneDropdownState extends State<_SelectSceneDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: [
        for (SceneModel scene in widget.scenes)
          DropdownMenuItem(
            value: scene.name,
            child: TextHelper.normal(context, scene.name),
          ),
      ],
      onChanged: (val) {
        widget.onChanged(
            widget.scenes.firstWhere((element) => element.name == val));
      },
      value: widget.currentScene?.name,
      style: Theme
          .of(context)
          .textTheme
          .bodyMedium,
      hint: TextHelper.normal(context, "Select A Scene"),
    );
  }
}
