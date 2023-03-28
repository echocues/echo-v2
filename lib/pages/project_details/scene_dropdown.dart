import 'package:echocues/api/models/scene.dart';
import 'package:echocues/components/validated_text_field.dart';
import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class SceneDropdown extends StatefulWidget {
  final List<SceneModel> scenes;
  final Function(SceneModel?) sceneChanged;
  final SceneModel? initialEditingModel;

  const SceneDropdown(
      {Key? key,
      required this.scenes,
      required this.sceneChanged,
      this.initialEditingModel})
      : super(key: key);

  @override
  State<SceneDropdown> createState() => _SceneDropdownState();
}

class _SceneDropdownState extends State<SceneDropdown> {
  SceneModel? editingModel;

  @override
  void initState() {
    super.initState();
    editingModel = widget.initialEditingModel;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: DropdownButton<String>(
            items: [
              for (SceneModel scene in widget.scenes)
                DropdownMenuItem(
                  value: scene.name,
                  child: TextHelper.normal(context, scene.name),
                ),
            ],
            onChanged: (val) {
              setState(() {
                _setEditingScene(
                    widget.scenes.firstWhere((element) => element.name == val));
              });
            },
            value: editingModel?.name,
            style: Theme.of(context).textTheme.bodyMedium,
            hint: TextHelper.normal(context, "Get started by creating a scene"),
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return _TextDialog(
                  onConfirm: (name) {
                    setState(() {
                      var scene = SceneModel(name: name, events: []);
                      widget.scenes.add(scene);
                      _setEditingScene(scene);
                    });
                    Navigator.pop(dialogContext);
                  },
                  onCancel: () {
                    Navigator.pop(dialogContext);
                  }, 
                  title: "Create Scene",
                  defaultValue: "New Scene",
                );
              },
            );
          },
          child: TextHelper.normal(context, "Create Scene"),
        ),
        TextButton(
          onPressed: editingModel == null ? null : () {
            widget.scenes.remove(editingModel);
            _setEditingScene(widget.scenes.isEmpty ? null : widget.scenes.first);
          },
          child: TextHelper.normal(context, "Delete Scene"),
        ),
        TextButton(
          onPressed: editingModel == null ? null : () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return _TextDialog(
                  onConfirm: (name) {
                    setState(() {
                      editingModel!.name = name;
                    });
                    Navigator.pop(dialogContext);
                  },
                  onCancel: () {
                    Navigator.pop(dialogContext);
                  },
                  title: "Rename Scene",
                  defaultValue: editingModel!.name,
                );
              },
            );
          },
          child: TextHelper.normal(context, "Rename Scene"),
        )
      ],
    );
  }

  void _setEditingScene(SceneModel? sceneModel) {
    editingModel = sceneModel;
    widget.sceneChanged(editingModel);
  }
}

class _TextDialog extends StatefulWidget {
  final Function(String) onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String defaultValue;

  const _TextDialog({Key? key, required this.onConfirm, this.onCancel, required this.title, required this.defaultValue})
      : super(key: key);

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextHelper.title(context, widget.title),
      content: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ValidatedTextField<String>(
            defaultValue: widget.defaultValue,
            value: value,
            validator: (str) => str.isEmpty ? widget.defaultValue : str,
            onChanged: (str) => value = str,
            label: "Title"),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: () {
                  widget.onConfirm(value);
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
