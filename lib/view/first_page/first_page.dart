import 'package:flutter/material.dart';

import '../barcode_scanning/barcode_scanner_live.dart';
import '../barcode_scanning/barcode_scanner_manual.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Options',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerManual(),
                      ),
                    );
                  },
                  child: const Text("Barcode Scanner"),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerLive(),
                      ),
                    );
                  },
                  child: const Text("Barcode Scanner Live"),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("About This App"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
