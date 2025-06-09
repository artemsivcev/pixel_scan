import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class EditorScreen extends StatelessWidget {
  final File file;

  const EditorScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      file,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          final directory = await Directory.systemTemp.createTemp();
          final editedFile = File(
              '${directory.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
          final newFile = await editedFile.writeAsBytes(bytes);

          if (context.mounted) {
            context.pop(newFile.path);
          }
        },
      ),
    );
  }
}
