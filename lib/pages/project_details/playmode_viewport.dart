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
import 'package:uuid/uuid.dart';

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
  late List<EventModel> eventsNeedResolving;

  @override
  void initState() {
    super.initState();
    _editingScene = widget.scene;
    eventsNeedResolving = [];
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
            children: eventsNeedResolving.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
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
                            if (event.cues.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextHelper.largeText(context, "Cues"),
                              ),
                              ...event.cues.map((e) => _PlayCueButton(soundCue: widget.soundCues.firstWhere((element) => element.identifier == e))),
                            
                            if (event.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextHelper.largeText(context, "Notes"),
                              ),
                              ...event.notes.map((e) => Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: TextHelper.normal(context, "\u2022  $e"),
                              )),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => setState(() => eventsNeedResolving.remove(event)),
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
          eventsNeedResolving.clear();

          _timeWatcher?.cancel();
          _timeWatcher = null;

          _timeRunner?.stop();
          _timeRunner = null;
        });
      },
      onStart: () {
        setState(() {
          _timeWatcher = Timer.periodic(const Duration(seconds: 1), (timer) {

            _timeRunner ??= Stopwatch();
            _timeRunner!.start();

            var added = false;

            for (var event in _editingScene!.events.where((element) =>
            element.time.toSeconds() == _timeRunner!.elapsed.inSeconds)) {
              if (eventsNeedResolving.contains(event)) continue;
              eventsNeedResolving.add(event);
              added = true;
            }

            if (added) {
              setState(() {});
            }
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
    );
  }
}

class _PlayModeControls extends StatelessWidget {

  final SceneModel? currentScene;
  final List<SceneModel> scenes;
  final VoidCallback onReset;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final Function(SceneModel) onSelectScene;
  final bool isPlaying;

  const _PlayModeControls({Key? key,
    required this.scenes,
    required this.onReset,
    required this.onSelectScene,
    required this.onStart,
    required this.currentScene,
    required this.isPlaying,
    required this.onPause,})
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

  const _PlayCueButton({Key? key, required this.soundCue}) : super(key: key);

  @override
  State<_PlayCueButton> createState() => _PlayCueButtonState();
}

class _PlayCueButtonState extends State<_PlayCueButton> {
  late AudioManager _audioPlayer;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioManager(
      audioPlayer: AudioPlayer(playerId: const Uuid().v4()),
    );
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

            var instance = await SharedPreferences.getInstance();
            var projectId = instance.getString("editingProject");

            await _audioPlayer.start(
                ServerCaller.audioSource(projectId!, widget.soundCue.fileName),
                widget.soundCue, onComplete: () {
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
