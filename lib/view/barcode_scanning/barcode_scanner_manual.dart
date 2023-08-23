// ignore_for_file: unnecessary_null_comparison

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

        //  suatu perangkat lunak atau kode program telah menyelesaikan penggunaan objek "scanner".
        barcodeScanner.close();

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
