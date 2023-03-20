import 'package:flutter/material.dart';

class TextHelper {
  static Text display(BuildContext buildContext, String data) {
    return Text(data, style: Theme.of(buildContext).textTheme.displayMedium,);
  }
  
  static Text normal(BuildContext buildContext, String data) {
    return Text(data, style: Theme.of(buildContext).textTheme.bodyMedium,);
  }

  static Text largeText(BuildContext buildContext, String data) {
    return Text(data, style: Theme.of(buildContext).textTheme.bodyLarge,);
  }

  static Text title(BuildContext buildContext, String data) {
    return Text(data, style: Theme.of(buildContext).textTheme.titleLarge,);
  }
}