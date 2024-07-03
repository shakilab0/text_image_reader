import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;
import 'package:text_image_reader/face_display_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _resultText = '';
  List<Face> _faces = [];
  ui.Image? iimage;
  List<ui.Image> croppedFaces = [];
  List<Uint8List> croppedFacesData = [];

  Future pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemp = File(image.path);
    setState(()  {
      _image = imageTemp;
      _performOCR();
      _loadImage(imageTemp);
      _detectFaces();
    });
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => iimage = value);
  }

  Future _performOCR() async {
    if (_image != null) {
      final result = await recognizeText(_image!);
      setState(() {
        _resultText = result;
      });
    }
  }

  Future _detectFaces() async {
    if (_image != null) {
      final inputImage = InputImage.fromFile(_image!);
      final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions());
      final faces = await faceDetector.processImage(inputImage);
       await _cropFaces(_image!, faces);
      setState(() {
        _faces = faces;
      });

    }
  }

  Future<String> recognizeText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    final recognisedText = await textDetector.processImage(inputImage);

    String resultText = '';
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        resultText += '${line.text}\n';
      }
    }
    return resultText;
  }

  Future<void> _cropFaces(File imageFile, List<Face> faces) async {
    final bytes = await imageFile.readAsBytes();
    final originalImage = await decodeImageFromList(bytes);

    for (var face in faces) {
      final faceRect = face.boundingBox;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, faceRect);

      canvas.drawImageRect(
        originalImage,
        faceRect,
        Rect.fromLTWH(0, 0, faceRect.width, faceRect.height),
        Paint(),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(faceRect.width.toInt(), faceRect.height.toInt());
      croppedFaces.add(img);
      //pass image in byte Start
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final uint8list = byteData.buffer.asUint8List();
        croppedFacesData.add(uint8list);
      }
    }
    // pass image in byte end
    setState(() {});

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Text and Face '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            _image != null
                ? Image.file(_image!)
                : Icon(Icons.image,size: 120,),
            SizedBox(height: 20),

            _faces.isNotEmpty
                ? FittedBox(
              child: SizedBox(
                width: iimage?.width.toDouble(),
                height: iimage?.height.toDouble(),
                child: CustomPaint(
                  painter: FacePainter(iimage!, _faces),
                ),
              ),
            )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera),
                  child: Text('Camera'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: Text('Gallery'),
                ),
              ],
            ),


            const SizedBox(height: 20),
            Text(_resultText),
            const SizedBox(height:40),
            Text('Faces detected: ${_faces.length}'),
            const SizedBox(height:20),
            InkWell(
              onTap: (){
                if(croppedFaces.isNotEmpty){
                  if (_faces.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => FaceDisplayPage(croppedFaces: croppedFaces, croppedFacesData: croppedFacesData,),
                    ),
                    );
                  }
                }
              },
              child: Container(
                color: Colors.blue,
                height: 45,
                child: const Center(child: Text("All Detect Faces",style: TextStyle(fontSize: 22,color: Colors.white),)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FacePainter extends CustomPainter {
  ui.Image image;
  List<Face> faces;
  List<Rect> boundingBoxes = [];//use rectangle
  List<Offset> centers = [];//use circle
  List<double> radii = [];//use circle
  FacePainter(this.image, this.faces) {
    for (var face in faces) {
      boundingBoxes.add(face.boundingBox);

      //use Circle
      final rect = face.boundingBox;
      final centerX = rect.left + rect.width / 2;
      final centerY = rect.top + rect.height / 2;
      final radius = (rect.width + rect.height) / 4;
      centers.add(Offset(centerX, centerY));
      radii.add(radius);

    }
  }
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint boundingBoxPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 40.0
      ..color = Colors.grey.withOpacity(0.9);


    canvas.drawImage(image, Offset.zero, Paint()); //draw rectangle around face
    //draw facecontour
    for (var i = 0; i < faces.length; i++) {
      //canvas.drawRect(boundingBoxes[i], boundingBoxPaint);// use rectangle
      canvas.drawCircle(centers[i], radii[i], boundingBoxPaint);//use Circle
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}