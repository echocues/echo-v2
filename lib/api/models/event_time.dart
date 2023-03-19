class EventTime {
  EventTime({
      this.hour = 0, 
      this.minutes = 0, 
      this.seconds = 0,
  });

  EventTime.fromJson(dynamic json) {
    hour = json['hour'];
    minutes = json['minutes'];
    seconds = json['seconds'];
  }
  
  late int hour;
  late int minutes;
  late int seconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hour'] = hour;
    map['minutes'] = minutes;
    map['seconds'] = seconds;
    return map;
  }

  @override
  String toString() {
    return "$hour:$minutes:$seconds";
  }
}