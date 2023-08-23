// ignore_for_file: unnecessary_null_comparison

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/*
kelas FacePainter ini bertanggung jawab untuk menggambar persegi panjang wajah 
(bounding box) dan landmark wajah (seperti mata, telinga, dan lainnya) pada kanvas, 
menggunakan data yang diberikan melalui facesList dan imageFile.

CustomPainter adalah kelas dalam Flutter yang memungkinkan Anda untuk menggambar
elemen visual kustom pada kanvas (canvas) di dalam widget CustomPaint.
*/
class FacePainter extends CustomPainter {
  /*
  Mendefinisikan dua properti pada kelas FacePainter. facesList adalah daftar 
  objek Face yang akan digambar, dan imageFile adalah gambar yang akan digunakan 
  sebagai latar belakang.
  */
  List<Face> facesList;
  dynamic imageFile;
  // Konstruktor kelas FacePainter yang menerima facesList dan imageFile sebagai parameter.
  FacePainter({required this.facesList, @required this.imageFile});

// Method yang diwarisi dari CustomPainter yang digunakan untuk melakukan penggambaran.
  @override
  void paint(Canvas canvas, Size size) {
    /*
    Memeriksa apakah imageFile tidak null. Jika tidak null, gambar latar belakang 
    diambil dari imageFile dan digambar pada posisi (0, 0) pada kanvas menggunakan 
    canvas.drawImage.
    */
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    //  Mengatur properti Paint yang diberi nama p dengan warna merah, style garis (stroke) dengan PaintingStyle.stroke, dan lebar garis 3.
    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    /*
    Melakukan loop melalui setiap objek Face dalam facesList. Untuk setiap Face,
    menggambar persegi panjang (bounding box) wajah dengan menggunakan canvas.drawRect dan p.
    */
    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
    }

    // Mengatur properti Paint baru bernama p2 dengan warna hijau,
    // style garis (stroke), dan lebar garis 1.
    Paint p2 = Paint();
    p2.color = Colors.green;
    p2.style = PaintingStyle.stroke;
    p2.strokeWidth = 1;

    // Mengatur properti Paint baru bernama p3 dengan warna kuning,
    // style garis (stroke), dan lebar garis 3.
    Paint p3 = Paint();
    p3.color = Colors.yellow;
    p3.style = PaintingStyle.stroke;
    p3.strokeWidth = 3;

    /*
    Melakukan loop lagi melalui setiap objek Face dalam facesList. Untuk setiap Face, 
    mengambil daftar kontur wajah dan menggambar titik-titik kontur dengan canvas.
    drawPoints menggunakan p2.
    
    Jika landmark detection diaktifkan, menggambar persegi panjang kecil di sekitar 
    titik landmark telinga kiri dengan canvas.drawRect dan p3.
    */
    for (Face face in facesList) {
      Map<FaceContourType, FaceContour?> con = face.contours;
      List<Offset> offsetPoints = <Offset>[];
      con.forEach((key, value) {
        if (value != null) {
          List<Point<int>>? points = value.points;
          for (Point p in points) {
            Offset offset = Offset(p.x.toDouble(), p.y.toDouble());
            offsetPoints.add(offset);
          }
          canvas.drawPoints(PointMode.points, offsetPoints, p2);
        }
      });

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark leftEar = face.landmarks[FaceLandmarkType.leftEar]!;
      if (leftEar != null) {
        final Point<int> leftEarPos = leftEar.position;
        canvas.drawRect(
            Rect.fromLTWH(leftEarPos.x.toDouble() - 5,
                leftEarPos.y.toDouble() - 5, 10, 12),
            p3);
      }
    }
  }

/*
Metode ini memberi tahu Flutter apakah repaint diperlukan saat terjadi
perubahan pada widget yang menggunakan CustomPaint. Dalam hal ini, 
selalu mengembalikan true, yang berarti repaint akan selalu dilakukan saat terjadi perubahan.
*/
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
