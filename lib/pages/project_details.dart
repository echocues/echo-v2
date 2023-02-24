import 'package:echocues/api/models/soundcue_model.dart';
import 'package:echocues/pages/project_details/playmode_page.dart';
import 'package:echocues/pages/project_details/soundcues_page.dart';
import 'package:echocues/pages/project_details/timelines_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectDetailsPageWidget extends StatelessWidget {
  static const String route = "/projects/details/";
  
  const ProjectDetailsPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ProjectModel model = ModalRoute.of(context)!.settings.arguments as ProjectModel;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            // model.title!,
            "Project Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.surround_sound),
                    ),
                    Text("Sound Cues"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.timeline),
                    ),
                    Text("Timeline"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.play_arrow),
                    ),
                    Text("Play Mode"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SoundCuesPageWidget(soundCuesData: [
              SoundCue(name: "Test", file: "Test.mp3", easeIn: true, easeOut: true, volume: 1.0, pitch: 1.0)
            ]),
            const TimelinePageWidget(),
            const PlayModePageWidget(),
          ],
        ),
      ),
    );
  }
}