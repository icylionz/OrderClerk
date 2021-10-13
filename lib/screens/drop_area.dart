import 'dart:io';

import 'package:OrderClerk/models/models.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DropArea extends StatefulWidget {
  final Function(List<File>) getFilesCallback;
  const DropArea({Key? key, required this.getFilesCallback}) : super(key: key);

  @override
  _DropArea createState() => _DropArea();
}

class _DropArea extends State<DropArea> {
  Uri? _uploaded;

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          _uploaded = detail.urls.first;
          widget.getFilesCallback(<File>[File(_uploaded!.toFilePath())]);
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: InkWell(
        onTap: () async {
          FilePickerResult? filePicked = await FilePicker.platform
              .pickFiles(type: FileType.image, allowedExtensions: [
            "jpeg",
            "png",
            "svg",
          ]);
          if (filePicked != null &&
              filePicked.isSinglePick &&
              filePicked.files.first.path != null) {
            setState(() {
              _uploaded = Uri.file(filePicked.files.first.path!);

              widget
                  .getFilesCallback(<File>[File(filePicked.files.first.path!)]);
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                  width: 2,
                  style: BorderStyle.solid,
                  color: _dragging
                      ? Theme.of(context).accentColor
                      : Settings.darkModeVal
                          ? Colors.white
                          : Colors.black)),
          child: Stack(
            children: [
              if (_uploaded == null)
                const Center(child: Text("Drop here"))
              else
                Image.file(File(_uploaded!.toFilePath())),
            ],
          ),
        ),
      ),
    );
  }
}
