import 'package:echocues/api/models/project_model.dart';
import 'package:echocues/pages/project_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectButton extends StatelessWidget {
  final ProjectModel project;

  const ProjectButton({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth * 2.75,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.pushNamed(
                context,
                ProjectDetailsPageWidget.route,
                arguments: project,
              );
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.square(
                          dimension: constraints.maxWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: Text(
                            project.title!,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth / 12,
                            ),
                          ),
                        ),
                        Text(
                          project.description!,
                          style: GoogleFonts.notoSans(
                            fontSize: constraints.maxWidth / 14,
                          ),
                        ),
                      ],
                    );
                  },
                )),
          ),
        );
      },
    );
  }
}
