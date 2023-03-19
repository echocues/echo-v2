import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class LabeledWidget extends StatelessWidget {
  final String label;
  final Widget child;
  
  const LabeledWidget({Key? key, required this.label, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextHelper.normal(context, label),
        child,
      ],
    );
  }
}
