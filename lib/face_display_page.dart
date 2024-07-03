import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;


class FaceDisplayPage extends StatelessWidget {
  final List<ui.Image> croppedFaces;
  final List<Uint8List> croppedFacesData;

const FaceDisplayPage({Key? key, required this.croppedFaces,required this.croppedFacesData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cropped Faces'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            mainAxisExtent: 360.0
        ),
        itemCount: croppedFacesData.length,
        itemBuilder: (context, index) {
          final faceImage = croppedFacesData[index];
          return croppedFacesData != null
              ? Image.memory(faceImage)
              : const Icon(Icons.photo_camera_back_outlined,color: Colors.blue,);
        },
      ),
      /*body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            mainAxisExtent: 360.0

        ),
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
      ),*/
    );
  }
}


