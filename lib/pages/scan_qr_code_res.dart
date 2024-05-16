import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'money_time_counter_page.dart';
import 'ebike_model.dart';

class ScanQRCodeResPage extends StatefulWidget {
  final Ebike ebike ;
  const ScanQRCodeResPage({super.key , required this.ebike });

  @override
  ScanQRCodeResPageState createState() => ScanQRCodeResPageState();
}

class ScanQRCodeResPageState extends State<ScanQRCodeResPage> {
  String qrCode = '';

  @override
  Widget build(BuildContext context) {
    return QrCamera(
      qrCodeCallback: (code) {
        setState(() {
          qrCode = code!;
          if (qrCode == widget.ebike.name ) {
             Navigator.pushReplacement(
             context,
             MaterialPageRoute(
               builder: (context) => MoneyTimeCounterPage(qrCode: code),
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