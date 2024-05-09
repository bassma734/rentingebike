// scan_qr_code_page.dart
import 'package:flutter/material.dart';

class ScanQRCodePage extends StatelessWidget {
  const ScanQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: const Center(
        child: Text('Scan QR Code'),
      ),
    );
  }
}