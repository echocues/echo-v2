import 'package:echocues/api/models/project_model.dart';
import 'package:echocues/components/project_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockholm/stockholm.dart';

class ProjectPageWidget extends StatefulWidget {
  static const String route = "/projects";

  const ProjectPageWidget({Key? key}) : super(key: key);

  @override
  State<ProjectPageWidget> createState() => _ProjectPageWidgetState();
}

class _ProjectPageWidgetState extends State<ProjectPageWidget> {
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
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text(
                        "Create Project",
                        style: GoogleFonts.poppins(),
                      ),
                      content: SizedBox(
                        height: 170,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextField(
                                controller: _titleInput,
                                decoration: const InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            TextField(
                              controller: _descriptionInput,
                              keyboardType: TextInputType.multiline,
                              minLines: 5,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(),
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
                              child: StockholmButton(
                                child: Text("Confirm", style: GoogleFonts.notoSans(),),
                                onPressed: () {
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16, bottom: 16),
                              child: StockholmButton(
                                child: Text("Cancel", style: GoogleFonts.notoSans(),),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
              return GridView.count(
                crossAxisCount: (constraints.maxWidth / 200).round(),
                childAspectRatio: 1 / 1.5,
                children: [
                  ProjectButton(
                    project: ProjectModel(title: "Test1"),
                  ),
                  ProjectButton(
                    project: ProjectModel(title: "Test2"),
                  ),
                  ProjectButton(
                    project: ProjectModel(title: "Test3"),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
