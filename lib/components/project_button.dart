import 'package:echocues/api/server_caller.dart';
import 'package:echocues/pages/project_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/models/project.dart';

enum _ContextOptions {
  delete,
  rename,
}

class ProjectButton extends StatelessWidget {
  final ProjectModel project;
  final Function onDelete;

  const ProjectButton({Key? key, required this.project, required this.onDelete}) : super(key: key);

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
                            project.title,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth / 12,
                            ),
                          ),
                        ),
                        Text(
                          project.description,
                          style: GoogleFonts.notoSans(
                            fontSize: constraints.maxWidth / 14,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: PopupMenuButton<_ContextOptions>(
                            splashRadius: 15,
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: _ContextOptions.delete,
                                child: Text("Delete"),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                            onSelected: (option) async {
                              switch (option) {
                                case _ContextOptions.delete:
                                  await ServerCaller.deleteProject(project.projectId)
                                    .whenComplete(() => onDelete());
                                  break;
                                case _ContextOptions.rename:
                                  // TODO: Handle this case.
                                  break;
                              }
                            },
                          ),
                        )
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
