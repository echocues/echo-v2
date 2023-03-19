import 'event.dart';

class SceneModel {
  SceneModel({
      required this.name, 
      required this.events,});

  SceneModel.fromJson(dynamic json) {
    name = json['name'];
    if (json['events'] != null) {
      events = [];
      json['events'].forEach((v) {
        events.add(EventModel.fromJson(v));
      });
    }
  }
  
  late String name;
  late List<EventModel> events;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['events'] = events.map((v) => v.toJson()).toList();
    return map;
  }

}