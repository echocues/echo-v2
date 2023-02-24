import 'package:echocues/api/models/scene_model.dart';

import 'soundcue_model.dart';

class ProjectModel {
  ProjectModel({
      this.projectId = "projectId", 
      this.title = "Title",
      this.description = "Description", 
      this.soundCues, 
      this.scenes,});

  ProjectModel.fromJson(dynamic json) {
    projectId = json['projectId'];
    title = json['title'];
    description = json['description'];
    soundCues = [];
    scenes = [];
    
    if (json['soundCues'] != null) {
      json['soundCues'].forEach((v) {
        soundCues!.add(SoundCue.fromJson(v));
      });
    }
    if (json['scenes'] != null) {
      json['scenes'].forEach((v) {
        scenes!.add(SceneModel.fromJson(v));
      });
    }
  }
  
  String? projectId;
  String? title;
  String? description;
  List<SoundCue>? soundCues;
  List<SceneModel>? scenes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['projectId'] = projectId;
    map['title'] = title;
    map['description'] = description;
    if (soundCues != null) {
      map['soundCues'] = soundCues!.map((v) => v.toJson()).toList();
    }
    if (scenes != null) {
      map['scenes'] = scenes!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}