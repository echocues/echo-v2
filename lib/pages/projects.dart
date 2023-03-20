import 'package:echocues/api/server_caller.dart';
import 'package:echocues/components/project_button.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/models/project.dart';

class ProjectPageWidget extends StatefulWidget {
  static const String route = "/projects";

  const ProjectPageWidget({Key? key}) : super(key: key);

  @override
  State<ProjectPageWidget> createState() => _ProjectPageWidgetState();
}

class _ProjectPageWidgetState extends State<ProjectPageWidget> {
  late Future<List<ProjectModel>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = ServerCaller.getProjects("AYJ");
  }

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
            TextButton(
              child: Text(
                "Create Project",
                style: GoogleFonts.poppins(),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return _CreateProjectDialog(
                      onConfirm: (title, description) async {
                        await ServerCaller.createProject("AYJ", title.text, description.text)
                            .whenComplete(() => setState(() {
                                  _projects = ServerCaller.getProjects("AYJ");
                                  Navigator.pop(dialogContext);
                                }));
                      },
                      onCancel: () {
                        Navigator.pop(dialogContext);
                      },
                    );
                  },
                );
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return FutureBuilder(
                future: _projects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GridView.count(
                      crossAxisCount: (constraints.maxWidth / 200).round(),
                      childAspectRatio: 1 / 1.5,
                      children: snapshot.data != null
                          ? snapshot.data!
                              .map((e) => ProjectButton(
                                    project: e,
                                    onDelete: () => setState(() {
                                      _projects =
                                          ServerCaller.getProjects("AYJ");
                                    }),
                                  ))
                              .toList()
                          : [],
                    );
                  }
                  return const CircularProgressIndicator();
                },
              );
            },
          ),
        ));
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final Function(TextEditingController, TextEditingController) onConfirm;
  final VoidCallback? onCancel;

  const _CreateProjectDialog({Key? key, required this.onConfirm, this.onCancel}) : super(key: key);

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  late TextEditingController _titleInput;
  late TextEditingController _descriptionInput;

  @override
  void initState() {
    super.initState();
    _titleInput = TextEditingController();
    _descriptionInput = TextEditingController();
  }

  @override
  void dispose() {
    _titleInput.dispose();
    _descriptionInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextHelper.title(context, "Create Project"),
      content: SizedBox(
        height: 160,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: _titleInput,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _descriptionInput,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: () {
                  widget.onConfirm(_titleInput, _descriptionInput);
                },
                child: TextHelper.normal(context, "Confirm"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: widget.onCancel,
                child: TextHelper.normal(context, "Cancel"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
