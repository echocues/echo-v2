import 'package:echocues/utilities/text_helper.dart';
import 'package:flutter/material.dart';

class PlaymodeViewport extends StatelessWidget {
  const PlaymodeViewport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: TextHelper.title(context, "NOT YET IMPLEMENTED"),
      ),
    );
  }
}
