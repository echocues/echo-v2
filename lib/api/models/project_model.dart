import 'soundcue_model.dart';
import 'timeline_model.dart';

class ProjectModel {
  ProjectModel({
      this.projectId, 
      this.title, 
      this.description, 
      this.soundCues, 
      this.timeline,});

  ProjectModel.fromJson(dynamic json) {
    projectId = json['projectId'];
    title = json['title'];
    description = json['description'];
    soundCues = [];
    timeline = [];
    
    if (json['soundCues'] != null) {
      json['soundCues'].forEach((v) {
        soundCues!.add(SoundCue.fromJson(v));
      });
    }
    if (json['timeline'] != null) {
      json['timeline'].forEach((v) {
        timeline!.add(Timeline.fromJson(v));
      });
    }
  }
  
  String? projectId;
  String? title;
  String? description;
  List<SoundCue>? soundCues;
  List<Timeline>? timeline;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['projectId'] = projectId;
    map['title'] = title;
    map['description'] = description;
    if (soundCues != null) {
      map['soundCues'] = soundCues!.map((v) => v.toJson()).toList();
    }
    if (timeline != null) {
      map['timeline'] = timeline!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}