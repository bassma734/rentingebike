import 'package:flutter/material.dart';
import 'package:renting_app/pages/scan_qr_code_res.dart';
//import 'reservation_form_page.dart';
import '../pages/ebike_model.dart';


class SuccessfulConfirmationPage extends StatelessWidget {
  final Ebike ebike ;

  const SuccessfulConfirmationPage({  required this.ebike ,super.key});

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
            const SizedBox(height : 20), 
            const Text(
              'Scan the QR code when you get there.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height : 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanQRCodeResPage(ebike : ebike),
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
