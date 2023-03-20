import 'dart:typed_data';

import 'package:echocues/api/server_caller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/models/soundcue.dart';

class SoundFileSelector extends StatefulWidget {
  final SoundCue soundCue;
  
  const SoundFileSelector({Key? key, required this.soundCue}) : super(key: key);

  @override
  State<SoundFileSelector> createState() => _SoundFileSelectorState();
}

class _SoundFileSelectorState extends State<SoundFileSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            "Sound File: \"${widget.soundCue.fileName}\"",
            style: GoogleFonts.notoSans(),
          ),
        ),
        TextButton(
            child: Text(
              "Select Sound File",
              style: GoogleFonts.notoSans(),
            ),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio,);
              if (result != null) {
                PlatformFile file = result.files.single;
                Uint8List? data = file.bytes;
                if (data == null) return;
                var instance = await SharedPreferences.getInstance();
                var projectId = instance.getString("editingProject");
                // TODO because this setState does not rebuild SoundCuePage the expansion tile does not
                // get rebuilt so the title does not change properly 
                await ServerCaller.uploadAudio(projectId!, file.name, data)
                    .whenComplete(() => setState(() => widget.soundCue.fileName = file.name));
              }
            }),
      ],
    );
  }
}
