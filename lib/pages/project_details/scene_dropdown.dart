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
                return _CreateSceneDialog(
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
                );
              },
            );
          },
          child: TextHelper.normal(context, "Create Scene"),
        ),
        TextButton(
          onPressed: () {
            if (editingModel == null) return;
            widget.scenes.remove(editingModel);
            _setEditingScene(widget.scenes.isEmpty ? null : widget.scenes.first);
          },
          child: TextHelper.normal(context, "Delete Scene"),
        )
      ],
    );
  }

  void _setEditingScene(SceneModel? sceneModel) {
    editingModel = sceneModel;
    widget.sceneChanged(editingModel);
  }
}

class _CreateSceneDialog extends StatefulWidget {
  final Function(String) onConfirm;
  final VoidCallback? onCancel;

  const _CreateSceneDialog({Key? key, required this.onConfirm, this.onCancel})
      : super(key: key);

  @override
  State<_CreateSceneDialog> createState() => _CreateSceneDialogState();
}

class _CreateSceneDialogState extends State<_CreateSceneDialog> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = "New Scene";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextHelper.title(context, "Create Scene"),
      content: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ValidatedTextField<String>(
            defaultValue: "New Scene",
            value: value,
            validator: (str) => str.isEmpty ? "New Scene" : str,
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
