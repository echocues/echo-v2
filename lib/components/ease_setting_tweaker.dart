import 'package:echocues/api/models/ease_settings.dart';
import 'package:echocues/components/float_text_field.dart';
import 'package:flutter/material.dart';

import 'labeled_widget.dart';

typedef SetEaseFunction = void Function(Function);

class EaseSettingsTweaker extends StatefulWidget {
  final String label;
  final EaseSettings settings;

  const EaseSettingsTweaker(
      {Key? key,
      required this.settings,
      required this.label})
      : super(key: key);

  @override
  State<EaseSettingsTweaker> createState() => _EaseSettingsTweakerState();
}

class _EaseSettingsTweakerState extends State<EaseSettingsTweaker> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return LabeledWidget(
        label: widget.label,
        child: Row(
          children: [
            Switch(
              value: widget.settings.enabled,
              onChanged: (value) {
                setState(() {
                  widget.settings.enabled = !widget.settings.enabled;
                });
              },
            ),
            if (widget.settings.enabled)
              SizedBox(
                width: constraints.maxWidth / 6,
                child: FloatTextField(
                  value: widget.settings.duration,
                  label: "Ease Duration",
                  onChanged: (value) {
                    widget.settings.duration = value;
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}
