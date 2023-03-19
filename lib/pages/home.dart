import 'package:echocues/pages/projects.dart';
import 'package:flutter/material.dart';

class HomePageWidget extends StatelessWidget {
  static const String route = "/";
  
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Echo Cues"),
        actions: [
          TextButton(
            child: const Text("Projects"),
            onPressed: () {
              Navigator.pushNamed(context, ProjectPageWidget.route);
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: const Text("Echo Cues"),
      ),
    );
  }
}