import 'dart:async';
import 'package:renting_app/pages/scan_qr_code_page.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class MoneyTimeCounterPage extends StatefulWidget {
  final String qrCode;

  const MoneyTimeCounterPage({super.key, required this.qrCode});

  @override
  MoneyTimeCounterPageState createState() => MoneyTimeCounterPageState();
}

class MoneyTimeCounterPageState extends State<MoneyTimeCounterPage> {
  double _moneyCounter = 0;
  String _moneyCounterFormatted = '0.00';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _moneyCounter += 0.0034;
        _moneyCounterFormatted =
          NumberFormat.currency(locale: 'ar_TN', symbol: 'DT')
              .format(_moneyCounter);      
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money and Time Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scanned QR Code: ${widget.qrCode}'),
            Text('Money: $_moneyCounterFormatted'),
            Text('Time: ${_timer!.tick} seconds'),
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