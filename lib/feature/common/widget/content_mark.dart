import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentMark extends StatelessWidget {
  const ContentMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Icon(
        CupertinoIcons.checkmark_seal_fill,
        size: 12,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
