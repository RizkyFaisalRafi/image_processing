// ignore_for_file: unnecessary_null_comparison

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
          // TODO: Handle this case wifi password.
          BarcodeWifi? barcodeWifi = barcode.value as BarcodeWifi;
          if (barcodeWifi != null) {
            String? ssid = barcodeWifi.ssid;
            String? password = barcodeWifi.password;

            result = "Wi-Fi SSID: $ssid\nPassword: $password";
          } else {
            result = "Invalid BarcodeWifi data";
          }
          break;
        case BarcodeType.url:
          // TODO: Handle this case url.
          BarcodeUrl? barcodeUrl = barcode.value as BarcodeUrl;

          if (barcodeUrl != null) {
            String? url = barcodeUrl.url;
            result = "URL: $url";
          } else {
            result = "Invalid BarcodeUrl data";
          }
          break;
        case BarcodeType.unknown:
          // TODO: Handle this case unknown.
          result = "Unknown barcode type: ${barcode.value}";
          break;
        case BarcodeType.contactInfo:
          // TODO: Handle this case contactInfo.
          BarcodeContactInfo? barcodeContactInfo =
              barcode.value as BarcodeContactInfo;

          String firstName = barcodeContactInfo.firstName ?? '';
          String middleName = barcodeContactInfo.middleName ?? '';
          String lastName = barcodeContactInfo.lastName ?? '';

          String fullName = '$firstName $middleName $lastName'.trim();
          String? phone = barcodeContactInfo.phoneNumbers.isNotEmpty
              ? barcodeContactInfo.phoneNumbers.first.number
              : '';
          String? email = barcodeContactInfo.emails.isNotEmpty
              ? barcodeContactInfo.emails.first.address
              : '';

          result =
              "Contact Information:\nName: $fullName\nPhone: $phone\nEmail: $email";
          break;
        case BarcodeType.email:
          // TODO: Handle this case email.
          BarcodeEmail? barcodeEmail = barcode.value as BarcodeEmail;

          if (barcodeEmail != null) {
            String? address = barcodeEmail.address;

            result = "Email Address: $address";
          } else {
            result = "Invalid BarcodeEmail data";
          }

          break;
        case BarcodeType.phone:
          // TODO: Handle this case.
          BarcodePhone? barcodePhone = barcode.value as BarcodePhone;

          if (barcodePhone != null) {
            String? phoneNumber = barcodePhone.number;

            result = "Phone Number: $phoneNumber";
          } else {
            result = "Invalid BarcodePhone data";
          }

          break;
        case BarcodeType.product:
          // TODO: Handle this case product.

          break;
        case BarcodeType.isbn:
          // TODO: Handle this case.

          break;
        case BarcodeType.sms:
          // TODO: Handle this case sms.
          final BarcodeSMS? barcodeSMS = barcode.value as BarcodeSMS?;

          if (barcodeSMS != null) {
            String? phoneNumber = barcodeSMS.phoneNumber;
            String? message = barcodeSMS.message;

            result = "Phone Number: $phoneNumber\nMessage: $message";
          } else {
            result = "Invalid BarcodeSMS data";
          }

          break;
        case BarcodeType.text:
          // TODO: Handle this case text.
          String? textValue = barcode.rawValue;

          result = "Text: $textValue";
          break;
        case BarcodeType.geoCoordinates:
          // TODO: Handle this case geoCoordinate.
          BarcodeGeoPoint? barcodeGeoPoint = barcode.value as BarcodeGeoPoint;

          double? latitude = barcodeGeoPoint.latitude;
          double? longitude = barcodeGeoPoint.longitude;

          result = "Latitude: $latitude\nLongitude: $longitude";
          break;
        case BarcodeType.calendarEvent:
          // TODO: Handle this case.
          BarcodeCalenderEvent? barcodeCalenderEvent =
              barcode.value as BarcodeCalenderEvent;

          String? summary = barcodeCalenderEvent.summary;
          String? organizer = barcodeCalenderEvent.organizer;
          String? description = barcodeCalenderEvent.description;
          String? location = barcodeCalenderEvent.location;
          String? start = barcodeCalenderEvent.start?.toString() ?? "N/A";
          String? end = barcodeCalenderEvent.end?.toString() ?? "N/A";

          result =
              "Event Title: $summary\norganizer: $organizer\nDescription: $description\nLocation: $location\nStart: $start\nEnd: $end";

          break;
        case BarcodeType.driverLicense:
          // TODO: Handle this case driverLicense.
          BarcodeDriverLicense? barcodeDriverLicense =
              barcode.value as BarcodeDriverLicense;

          String? firstName = barcodeDriverLicense.firstName;
          String? lastName = barcodeDriverLicense.lastName;
          String? licenseNumber = barcodeDriverLicense.licenseNumber;
          String? address = barcodeDriverLicense.addressCity;
          String? birthDate = barcodeDriverLicense.birthDate;
          String? issueDate = barcodeDriverLicense.issueDate;
          String? expiryDate = barcodeDriverLicense.expiryDate;
          String? gender = barcodeDriverLicense.gender;

          result =
              "Name: $firstName $lastName\nGender: $gender\nLicense Number: $licenseNumber\nAddress: $address\nBirth Date: $birthDate\nIssue Date: $issueDate\nExpiry Date: $expiryDate";

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
