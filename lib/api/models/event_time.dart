class EventTime {
  EventTime({
      this.hours = 0, 
      this.minutes = 0, 
      this.seconds = 0,
  });

  EventTime.fromJson(dynamic json) {
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
  }

  EventTime.fromSeconds(int seconds) {
    hours = seconds ~/ 3600;
    minutes = (seconds % 3600) ~/ 60;
    this.seconds = seconds % 60;
  }
  
  late int hours;
  late int minutes;
  late int seconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hours'] = hours;
    map['minutes'] = minutes;
    map['seconds'] = seconds;
    return map;
  }

  void addSeconds(int seconds) {
    this.seconds += seconds;
    format();
  }
  
  void format() {
    int durationInSeconds = toSeconds();
    
    if (durationInSeconds < 0) {
      hours = 0;
      minutes = 0;
      seconds = 0;
      return;
    }
    
    hours = durationInSeconds ~/ 3600;
    minutes = (durationInSeconds % 3600) ~/ 60;
    seconds = durationInSeconds % 60;
  }
  
  int toSeconds() {
    return hours * 3600 + minutes * 60 + seconds;
  }
  
  @override
  String toString() {
    return "$hours:$minutes:$seconds";
  }
  
  String toSmartString() {
    if (hours <= 0 && minutes <= 0 && seconds <= 0) {
      return "0s";
    }
    
    var res = "";
    
    if (hours > 0) {
      res += "${hours}h";
    }

    if (minutes > 0) {
      res += "${minutes}m";
    }

    if (seconds > 0) {
      res += "${seconds}s";
    }
    
    return res;
  }
}