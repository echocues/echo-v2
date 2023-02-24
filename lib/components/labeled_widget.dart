import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabeledWidget extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final Widget child;
  
  const LabeledWidget({Key? key, required this.label, this.style, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: style ?? GoogleFonts.notoSans(),),
        child,
      ],
    );
  }
}
