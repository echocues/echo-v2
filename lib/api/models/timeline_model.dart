class Timeline {
  Timeline({
      this.time, 
      this.cues, 
      this.notes,});

  Timeline.fromJson(dynamic json) {
    time = json['time'];
    cues = json['cues'] != null ? json['cues'].cast<String>() : [];
    notes = json['notes'] != null ? json['notes'].cast<String>() : [];
  }
  
  String? time;
  List<String>? cues;
  List<String>? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['cues'] = cues;
    map['notes'] = notes;
    return map;
  }
}