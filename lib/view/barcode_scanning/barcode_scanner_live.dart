import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerLive extends StatefulWidget {
  const BarcodeScannerLive({super.key});

  @override
  State<BarcodeScannerLive> createState() => _BarcodeScannerLiveState();
}

class _BarcodeScannerLiveState extends State<BarcodeScannerLive> {
  late List<CameraDescription> _cameras;

  // StreamSubscription<CameraImage>? _imageStreamSubscription;

  late CameraController cameraController;
  CameraImage? img;
  bool isBusy = false;
  String result = "results will be shown";
  // mlKit
  late InputImage inputImage;

  // Declare scanner
  dynamic barcodeScanner;

  @override
  void initState() {
    super.initState();

    startCamera(); // Inisialisasi kamera
  }

  void startCamera() async {
    _cameras = await availableCameras();

    // Initialize scanner
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);

    cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startImageStream((image) => {
            if (!isBusy)
              {
                isBusy = true,
                img = image,
                Future.microtask(
                  () {
                    doBarcodeScanning();
                  },
                ),
              }
          });
      setState(() {}); // To refresh Widget
    }).catchError((e) {
      print(e);
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  // TODO barcode scanning code here
  doBarcodeScanning() async {
    InputImage inputImage = getInputImage();

    // Process image
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      // final Rect? boundingBox = barcode.boundingBox;
      // final String? displayValue = barcode.displayValue;
      // final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi? barcodeWifi = barcode.value as BarcodeWifi;
          result = "Wifi:${barcodeWifi.password!}";
          break;
        case BarcodeType.url:
          BarcodeUrl? barcodeUrl = barcode.value as BarcodeUrl;

          result = "${barcodeUrl.url!}";
          break;
        case BarcodeType.unknown:
          // TODO: Handle this case.
          break;
        case BarcodeType.contactInfo:
          // TODO: Handle this case.
          break;
        case BarcodeType.email:
          // TODO: Handle this case.
          break;
        case BarcodeType.isbn:
          // TODO: Handle this case.
          break;
        case BarcodeType.phone:
          // TODO: Handle this case.
          break;
        case BarcodeType.product:
          // TODO: Handle this case.
          break;
        case BarcodeType.sms:
          // TODO: Handle this case.
          break;
        case BarcodeType.text:
          // TODO: Handle this case.
          break;
        case BarcodeType.geoCoordinates:
          // TODO: Handle this case.
          break;
        case BarcodeType.calendarEvent:
          // TODO: Handle this case.
          break;
        case BarcodeType.driverLicense:
          // TODO: Handle this case.
          break;
      }
    }
    if (mounted) {
      // check whether the state object is in tree
      setState(() {
        isBusy = false;
        result;
      });
    }

    // setState(() {
    //   isBusy = false;
    //   result;
    // });
  }

  // TODO: GetInputImage
  InputImage getInputImage() {
    // mengumpulkan semua byte gambar dari berbagai "plane" (bidang) gambar.
    final WriteBuffer allBytes = WriteBuffer();
    // loop yang akan berjalan melalui setiap plane (bidang) gambar dari input img.
    for (final Plane plane in img!.planes) {
      // Menambahkan byte gambar dari plane saat ini ke dalam objek WriteBuffer yang telah dibuat sebelumnya.
      allBytes.putUint8List(plane.bytes);
    }
    /*
    Setelah semua byte gambar dari semua plane telah dikumpulkan, metode done() 
    pada objek WriteBuffer dipanggil untuk menyelesaikan pengisian byte. 
    Hasilnya kemudian dikonversi menjadi Uint8List yang merepresentasikan semua byte gambar dari berbagai plane.
    */
    final bytes = allBytes.done().buffer.asUint8List();
    // Membuat objek Size yang merepresentasikan dimensi gambar (lebar dan tinggi) dari input img.
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    // Mengambil kamera pertama dari daftar kamera yang telah diinisialisasi sebelumnya.
    final camera = _cameras[0];
    // Mengambil nilai rotasi gambar dari orientasi sensor kamera. Nilai rotasi ini nantinya akan digunakan dalam objek InputImageData.
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // Mengambil format gambar dari input img. Nilai format ini juga akan digunakan dalam objek InputImageData.
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(img!.format.raw);

    /*
    Loop ini digunakan untuk membuat daftar metadata plane gambar yang nantinya
    akan digunakan dalam objek InputImageData.
*/
    final planeData = img!.planes.map(
      /*
    Masing-masing plane menghasilkan objek InputImagePlaneMetadata yang berisi 
    informasi tentang lebar, tinggi, dan bytes per baris dari plane tersebut.
    */
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

//  Membuat objek InputImageData yang berisi informasi tentang dimensi gambar, rotasi gambar, format gambar, dan metadata plane.
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

// Membuat objek InputImage dari byte gambar dan informasi data gambar yang telah dikumpulkan sebelumnya.
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
// Mengembalikan objek InputImage yang telah dibuat sebagai hasil akhir dari method getInputImage()
    return inputImage;
  }

  @override
  void dispose() {
    // _imageStreamSubscription?.cancel(); // Batalkan langganan aliran gambar
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(cameraController),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}
