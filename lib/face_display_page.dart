import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;


class FaceDisplayPage extends StatelessWidget {
  final List<ui.Image> croppedFaces;

  const FaceDisplayPage({Key? key, required this.croppedFaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cropped Faces'),
      ),
      body: ListView.builder(
        itemCount: croppedFaces.length,
        itemBuilder: (context, index) {
          final faceImage = croppedFaces[index];
          return FutureBuilder<Uint8List>(
            future: faceImage.toByteData(format: ui.ImageByteFormat.png).then((byteData) => byteData!.buffer.asUint8List()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Image.memory(snapshot.data!);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
