import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

import '../../config/face_painter.dart';

class FaceDetection extends StatefulWidget {
  const FaceDetection({super.key});

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  late ImagePicker imagePicker;
  File? _image;
  String result = '';
  dynamic image;
  late List<Face> faces;

  // Declare Detector
  dynamic faceDetector;

  // late FaceDetector faceDetector; // Pindahkan ke sini

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    // Initialize Detector
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableContours: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    faceDetector = FaceDetector(options: options);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  // TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doFaceDetection();
    }
  }

  // TODO face detection code here
  doFaceDetection() async {
    result = "";
    InputImage? inputImage = InputImage.fromFile(_image!);

    // Process image
    try {
      faces = await faceDetector.processImage(inputImage);
      print("Len: ${faces.length.toString()}");
    } catch (e) {
      print(e);
    }

    for (Face f in faces) {
      if (f.smilingProbability! > 0.5) {
        result += "Smiling";
      } else {
        result += "Serious";
      }
    }

    setState(() {
      _image;
      result;
    });
    drawRectangleAroundFaces();
  }

  //TODO draw rectangles
  drawRectangleAroundFaces() async {
    image = await _image?.readAsBytes();
    ui.Image decodedImage = await decodeImageFromList(image);
    image = decodedImage;

    setState(() {
      image;
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 100,
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: Stack(children: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: _imgFromGallery,
                    onLongPress: _imgFromCamera,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent),
                    child:
                        // Container(
                        //   margin: const EdgeInsets.only(top: 8),
                        //   child: _image != null
                        //       ? Image.file(
                        //           _image!,
                        //           width: 335,
                        //           height: 495,
                        //           fit: BoxFit.fill,
                        //         )
                        //       : Container(
                        //           width: 340,
                        //           height: 330,
                        //           color: Colors.black,
                        //           child: const Icon(
                        //             Icons.camera_alt,
                        //             color: Colors.white,
                        //             size: 100,
                        //           ),
                        //         ),
                        // ),

                        Container(
                      width: 335,
                      height: 495,
                      margin: const EdgeInsets.only(
                        top: 45,
                      ),
                      child: image != null
                          ? Center(
                              child: FittedBox(
                                child: SizedBox(
                                  width: image == null
                                      ? 335
                                      : image.width.toDouble(),
                                  height: image == null
                                      ? 495
                                      : image.width.toDouble(),
                                  child: CustomPaint(
                                    painter: FacePainter(
                                        facesList: faces, imageFile: image),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.black,
                              width: 340,
                              height: 330,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
