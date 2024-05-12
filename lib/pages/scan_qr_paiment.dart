import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import '../pages/paiement_page.dart';
class ScanQRCodePage extends StatefulWidget {
  const ScanQRCodePage({super.key});

  @override
  ScanQRCodePageState createState() => ScanQRCodePageState();
}

class ScanQRCodePageState extends State<ScanQRCodePage> {
  String qrCode = '';

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        setState(() {
          qrCode = code!;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>const PaiementPage(),
            ),
          );
        });
      },
      
      notStartedBuilder: (context) {
        return const Text("");
      },
      offscreenBuilder: (context) {
        return const Text("QR Code scanner paused");
      },
    );
  }
}