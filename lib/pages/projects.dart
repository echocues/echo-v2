import 'package:echocues/api/models/project_model.dart';
import 'package:echocues/components/project_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockholm/stockholm.dart';

class ProjectPageWidget extends StatelessWidget {
  static const String route = "/projects";

  const ProjectPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Projects",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StockholmButton(
            child: Text(
              "Create Project",
              style: GoogleFonts.poppins(),
            ),
            onPressed: () {
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return GridView.count(
              crossAxisCount: (constraints.maxWidth / 200).round(),
              childAspectRatio: 1 / 1.5,
              children: [
                ProjectButton(project: ProjectModel(),),
                ProjectButton(project: ProjectModel(),),
                ProjectButton(project: ProjectModel(),),
              ],
            );
          },
        ),
      )
    );
  }
}
