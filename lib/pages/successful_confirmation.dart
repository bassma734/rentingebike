import 'package:flutter/material.dart';
import 'package:renting_app/pages/scan_qr_code_page.dart';

class SuccessfulConfirmationPage extends StatelessWidget {
  const SuccessfulConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Successful Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your reservation has been confirmed successfully.',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height : 20), // Removed problematic characters from here
            const Text(
              'Scan the QR code when you get there.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height : 40), // Removed problematic characters from here
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanQRCodePage(),
                  ),
                );
              },
              child: const Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}