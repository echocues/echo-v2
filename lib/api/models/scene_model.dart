import 'package:echocues/api/models/timeline_model.dart';

class SceneModel {
  SceneModel({
    required this.name,
    required this.events,});

  SceneModel.fromJson(dynamic json) {
    name = json['name'];
    events = [];

    if (json['events'] != null) {
      json['events'].forEach((v) {
        events!.add(TimelineEventModel.fromJson(v));
      });
    }
  }

  String? name;
  List<TimelineEventModel>? events;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['events'] = events;
    return map;
  }
}