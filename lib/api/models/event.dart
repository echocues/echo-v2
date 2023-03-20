import 'event_time.dart';

class EventModel {
  EventModel({
      required this.time, 
      required this.cues, 
      required this.notes,});

  EventModel.fromJson(dynamic json) {
    time = json['time'] != null ? EventTime.fromJson(json['time']) : EventTime(hours: 0, minutes: 0, seconds: 0);
    cues = json['cues'] != null ? json['cues'].cast<String>() : [];
    notes = json['notes'] != null ? json['notes'].cast<String>() : [];
  }
  
  late EventTime time;
  late List<String> cues;
  late List<String> notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time.toJson();
    map['cues'] = cues;
    map['notes'] = notes;
    return map;
  }

}