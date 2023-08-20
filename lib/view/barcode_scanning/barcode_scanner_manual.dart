import 'dart:io';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeScannerManual extends StatefulWidget {
  const BarcodeScannerManual({super.key});

  @override
  State<BarcodeScannerManual> createState() => _BarcodeScannerManualState();
}

class _BarcodeScannerManualState extends State<BarcodeScannerManual> {
  late ImagePicker imagePicker;
  File? _image;
  String? result;
  // Declare Scanner
  late BarcodeScanner barcodeScanner;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    // Initialize scanner
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image picked from camera.');
    }
    // _image = File(pickedFile!.path);
    setState(() {
      _image;
      doBarcodeScanning();
    });
  }

  // Choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doBarcodeScanning();
      });
    } else {
      print("Something Went Wrong");
    }
  }

  // Barcode scanning code here
  doBarcodeScanning() async {
    // Pengecekan jika image null
    if (_image == null) {
      print("No image to process.");
      return;
    }

    InputImage? inputImage = InputImage.fromFile(_image!);

    // Process image
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    if (barcodes.isEmpty) {
      setState(() {
        result = "Kosong"; // Set result to "Kosong" if no barcode is detected
      });
    } else {
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

        setState(() {
          result ??= "Kosong"; // Set result to "Kosong" if result is null
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch URL
    void launchURL(String? url) async {
      // Menghapus skema yang ada (jika ada)
      url = url?.replaceAll(RegExp(r'^(http:\/\/|https:\/\/)'), '');
      final Uri linkUrl = Uri(scheme: 'https', path: url);

      if (await canLaunchUrl(linkUrl)) {
        await launchUrl(linkUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $linkUrl';
      }
    }

    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
                  ),
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        Center(
                          child: Image.asset(
                            'images/frame.jpg',
                            height: 350,
                            width: 350,
                          ),
                        ),
                      ]),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent),
                          onPressed: _imgFromGallery,
                          onLongPress: _imgFromCamera,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    width: 325,
                                    height: 325,
                                    fit: BoxFit.fill,
                                  )
                                : const SizedBox(
                                    width: 340,
                                    height: 330,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                      size: 100,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () {
                      // Memanggil fungsi _launchURL dengan URL sebagai argumen
                      launchURL(result);
                      // launchWhatsApp();
                    },
                    child: Text(
                      result ?? 'Kosong',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}