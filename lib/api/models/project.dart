import 'soundcue.dart';
import 'scene.dart';

class ProjectModel {
  ProjectModel({
      required this.projectId, 
      required this.title, 
      required this.description, 
      required this.soundCues, 
      required this.scenes,});

  ProjectModel.fromJson(dynamic json) {
    projectId = json['project_id'];
    title = json['title'];
    description = json['description'];
    if (json['sound_cues'] != null) {
      soundCues = [];
      json['sound_cues'].forEach((v) {
        soundCues.add(SoundCue.fromJson(v));
      });
    }
    if (json['scenes'] != null) {
      scenes = [];
      json['scenes'].forEach((v) {
        scenes.add(SceneModel.fromJson(v));
      });
    }
  }

  late String projectId;
  late String title;
  late String description;
  late List<SoundCue> soundCues;
  late List<SceneModel> scenes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['project_id'] = projectId;
    map['title'] = title;
    map['description'] = description;
    map['sound_cues'] = soundCues.map((v) => v.toJson()).toList();
    map['scenes'] = scenes.map((v) => v.toJson()).toList();
    return map;
  }

}