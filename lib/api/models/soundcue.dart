import 'ease_settings.dart';

class SoundCue {
  SoundCue({
      required this.identifier, 
      required this.fileName, 
      required this.easeIn, 
      required this.easeOut, 
      required this.volume,
      required this.speed,});

  SoundCue.fromJson(dynamic json) {
    identifier = json['identifier'];
    fileName = json['file_name'];
    easeIn = json['ease_in'] != null ? EaseSettings.fromJson(json['ease_in']) : EaseSettings(enabled: false, duration: 0);
    easeOut = json['ease_out'] != null ? EaseSettings.fromJson(json['ease_out']) : EaseSettings(enabled: false, duration: 0);
    volume = json['volume'];
    speed = json['speed'];
  }
  
  late String identifier;
  late String fileName;
  late EaseSettings easeIn;
  late EaseSettings easeOut;
  late double volume;
  late double speed;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['identifier'] = identifier;
    map['file_name'] = fileName;
    map['ease_in'] = easeIn.toJson();
    map['ease_out'] = easeOut.toJson();
    map['volume'] = volume;
    map['speed'] = speed;
    return map;
  }
}