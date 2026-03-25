
import 'package:flutter/material.dart';

import 'tr_text.dart';

class FileOptionsMenu extends StatelessWidget {
  final Function() onRename;
  final Function() onDelete;

  const FileOptionsMenu({
    super.key,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == "rename") {
          onRename();
        } else if (value == "delete") {
          onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: "rename",
          child: TrText("rename"),
        ),
        PopupMenuItem(
          value: "delete",
          child: TrText("delete"),
        ),
      ],
    );
  }
}