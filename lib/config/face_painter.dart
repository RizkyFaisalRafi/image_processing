import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
    }

    // Paint p2 = Paint();
    // p2.color = Colors.green;
    // p2.style = PaintingStyle.stroke;
    // p2.strokeWidth = 1;
    //
    // Paint p3 = Paint();
    // p3.color = Colors.yellow;
    // p3.style = PaintingStyle.stroke;
    // p3.strokeWidth = 1;
    //
    // for (Face face in facesList) {
    //   Map<FaceContourType, FaceContour?> con = face.contours;
    //   List<Offset> offsetPoints = <Offset>[];
    //   con.forEach((key, value) {
    //     if(value != null) {
    //       List<Point<int>>? points = value.points;
    //       for (Point p in points) {
    //         Offset offset = Offset(p.x.toDouble(), p.y.toDouble());
    //         offsetPoints.add(offset);
    //       }
    //       canvas.drawPoints(PointMode.points, offsetPoints, p2);
    //     }
    //   });
    //
    //   // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
    //   // eyes, cheeks, and nose available):
    //   final FaceLandmark leftEar = face.landmarks[FaceLandmarkType.leftEar]!;
    //   if (leftEar != null) {
    //     final Point<int> leftEarPos = leftEar.position;
    //     canvas.drawRect(Rect.fromLTWH(leftEarPos.x.toDouble()-5, leftEarPos.y.toDouble()-5,10,10),  p3);
    //   }
    //
    // }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
