class SoundCue {
  SoundCue({
    required this.name,
    required this.file,
    required this.easeIn,
    required this.easeOut,
    required this.volume,
    required this.pitch,});

  SoundCue.fromJson(dynamic json) {
    name = json['name'];
    file = json['file'];
    easeIn = json['easeIn'];
    easeOut = json['easeOut'];
    volume = json['volume'];
    pitch = json['pitch'];
  }

  String? name;
  String? file;
  bool? easeIn;
  bool? easeOut;
  double? volume;
  double? pitch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['file'] = file;
    map['easeIn'] = easeIn;
    map['easeOut'] = easeOut;
    map['volume'] = volume;
    map['pitch'] = pitch;
    return map;
  }
}