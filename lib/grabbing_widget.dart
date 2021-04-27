import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class MySnappingSheet extends StatefulWidget {
  final Widget _RandWords;
  firebase_storage.FirebaseStorage _storage;

  MySnappingSheet(this._RandWords, this._storage);

  @override
  _MySnappingSheetState createState() => _MySnappingSheetState();
}

class _MySnappingSheetState extends State<MySnappingSheet> {
  final _snapSheetController = SnappingSheetController();

  final List<SnappingPosition> _snapPos = [
    SnappingPosition.factor(
        positionFactor: 0.0,
        snappingDuration: Duration(milliseconds: 1200),
        snappingCurve: Curves.elasticInOut,
        grabbingContentOffset: 1),
    SnappingPosition.factor(
        positionFactor: 0.2,
        snappingDuration: Duration(milliseconds: 1200),
        snappingCurve: Curves.elasticInOut,
        grabbingContentOffset: 0)
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, auth, _) => SnappingSheet(
        child: widget._RandWords,
        controller: _snapSheetController,
        snappingPositions: _snapPos,
        grabbingHeight: 75,
        grabbing: _defaultGrabbing(auth),
        sheetBelow: _buildSheetBelow(auth, widget._storage),
      ),
    );
  }

  InkWell _defaultGrabbing(AuthRepository auth) {
    final Color color;
    final bool reverse;

    return InkWell(
      child: Container(
        child: Row(
          children: [
            Text("Welcome back, ${auth.user!.email}"),
            Icon(Icons.keyboard_arrow_up_rounded),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        color: Colors.grey,
        padding: const EdgeInsets.only(left: 16),
      ),
      onTap: () {
        setState(() {
          _snapSheetController.currentSnappingPosition == _snapPos[0]
              ? _snapSheetController.snapToPosition(_snapPos[1])
              : _snapSheetController.snapToPosition(_snapPos[0]);
        });
      },
    );
  }
}

class _GrabbingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Welcome to Startup Names Generator, please log in below',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, height: 1.5, color: Colors.black),
      ),
      height: 5,
      width: 75,
    );
  }
}

SnappingSheetContent _buildSheetBelow(AuthRepository auth, _storage) {
  return SnappingSheetContent(
      child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: auth.avatarURL!.isEmpty==false? DecorationImage(
                        image: NetworkImage(auth.avatarURL!),
                        fit: BoxFit.fill
                    ):null,
                  ),
                ),],
              ),
              Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("${auth.user!.email}", style: TextStyle(fontSize: 18),),
                    ElevatedButton(
                        onPressed: () {
                           avatarChange(auth, _storage);
                        },
                        style:
                            ElevatedButton.styleFrom(primary: Colors.teal[700]),
                        child: Text("Change Avatar"))
                  ])
            ],
          )));
}

Future<void> avatarChange (AuthRepository auth, _storage) async {

  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if(result != null) {

    File file = File(result.files.single.path!);
    var temp = await _storage.ref('${auth.user!.uid}').putFile(file);
    var url = await temp.ref.getDownloadURL();
    auth.changeAvatarURL(url);
  } else {
    // User canceled the picker
  }
}
