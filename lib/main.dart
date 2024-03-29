import 'package:echocues/pages/home.dart';
import 'package:echocues/pages/project_details.dart';
import 'package:echocues/pages/projects.dart';
import 'package:echocues/utilities/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      theme: Utils.defaultDarkTheme(),
      initialRoute: ProjectPageWidget.route,
      routes: {
        HomePageWidget.route: (ctx) => const HomePageWidget(),
        ProjectPageWidget.route: (ctx) => const ProjectPageWidget(),
        ProjectDetailsPageWidget.route: (ctx) => const ProjectDetailsPageWidget(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
