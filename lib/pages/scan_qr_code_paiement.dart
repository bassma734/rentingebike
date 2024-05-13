import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import '../pages/paiement_page.dart';
class ScanQRPCodePage extends StatefulWidget {
  const ScanQRPCodePage({super.key});

  @override
  ScanQRPCodePageState createState() => ScanQRPCodePageState();
}

class ScanQRPCodePageState extends State<ScanQRPCodePage> {
  String qrCode = '';

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        setState(() {
          qrCode = code!;
          if (code.startsWith('Ebike'))
      {
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>const PaiementPage(),
            ),
          );
        }});
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