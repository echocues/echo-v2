class EaseSettings {
  EaseSettings({
      required this.enabled, 
      required this.duration,});

  EaseSettings.fromJson(dynamic json) {
    enabled = json['enabled'];
    duration = json['duration'];
  }
  
  late bool enabled;
  late double duration;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['enabled'] = enabled;
    map['duration'] = duration;
    return map;
  }
}