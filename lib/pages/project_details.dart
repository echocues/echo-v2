import 'dart:async';

import 'package:echocues/api/server_caller.dart';
import 'package:echocues/pages/project_details/playmode_page.dart';
import 'package:echocues/pages/project_details/soundcues_page.dart';
import 'package:echocues/pages/project_details/scene_page.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/models/project.dart';

class ProjectDetailsPageWidget extends StatefulWidget {
  static const String route = "/projects/details/";

  const ProjectDetailsPageWidget({Key? key}) : super(key: key);

  @override
  State<ProjectDetailsPageWidget> createState() =>
      _ProjectDetailsPageWidgetState();
}

class _ProjectDetailsPageWidgetState extends State<ProjectDetailsPageWidget> {
  late ProjectModel? _projectModel;
  late Timer _autosaver;
  
  @override
  void initState() {
    super.initState();
    const onemin = Duration(minutes: 1);
    _autosaver = Timer.periodic(onemin, (timer) => save());
  }

  @override
  void dispose() async {
    super.dispose();
    save();
    _autosaver.cancel();
  }
  
  void save() async {
    if (_projectModel == null) return;
    await ServerCaller.saveProject(_projectModel!);
  }

  Future _getModel() async {
    var model = ModalRoute.of(context)!.settings.arguments as ProjectModel?;
    
    if (model != null) {
      _projectModel = model;
      var instance = await SharedPreferences.getInstance();
      await instance.setString("editingProject", _projectModel!.projectId);
      return;
    }

    var instance = await SharedPreferences.getInstance();
    _projectModel = await ServerCaller.getProject(instance.getString("editingProject")!);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getModel(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: TextHelper.display(ctx, "Project: ${_projectModel!.title}"),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.surround_sound),
                        ),
                        TextHelper.largeText(ctx, "Sound Cues"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.theaters),
                        ),
                        TextHelper.largeText(ctx, "Scenes"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.play_arrow),
                        ),
                        TextHelper.largeText(ctx, "Play Mode"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SoundCuesPageWidget(soundCuesData: _projectModel!.soundCues),
                ScenesPageWidget(
                  scenes: _projectModel!.scenes,
                ),
                const PlayModePageWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
