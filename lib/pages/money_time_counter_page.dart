import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'scan_qr_code_paiement.dart';
import '../core/constants.dart';

class MoneyTimeCounterPage extends StatefulWidget {
  final String qrCode;

  const MoneyTimeCounterPage({super.key, required this.qrCode});

  @override
  MoneyTimeCounterPageState createState() => MoneyTimeCounterPageState();
}

class MoneyTimeCounterPageState extends State<MoneyTimeCounterPage>
    with SingleTickerProviderStateMixin {
  double moneyCounter = 0;
  String _moneyCounterFormatted = '0.00';
  static Timer? timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _startTimer();
  }

 

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        moneyCounter += 0.0034;
        _moneyCounterFormatted = NumberFormat.currency(
          locale: 'ar_TN',
          symbol: 'DT',
        ).format(moneyCounter);
        _animationController.forward(from: 0);
      });
    });
  }

  void _navigateToScanPage() {
   // _timer?.cancel(); // Stop the timer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQRCodePage(
          name: widget.qrCode,
          amount: moneyCounter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSeconds = timer?.tick ?? 0;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(15, 79, 185, 234)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCustomCard(
                    title: 'Scanned QR Code',
                    content: Text(
                      widget.qrCode,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    icon: Icons.qr_code,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomCard(
                    title: 'Money',
                    content: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Text(
                          _moneyCounterFormatted,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        );
                      },
                    ),
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomCard(
                    title: 'Time',
                    content: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: (minutes % 60) / 60,
                      center: Text(
                        '$minutes:${seconds.toString().padLeft(2, '0')} m',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      progressColor: primary,
                    ),
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _navigateToScanPage,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCard({
    required String title,
    required Widget content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
  
  
=======
  @override
  void dispose() {
    //timer?.cancel();
    super.dispose();
  }
>>>>>>> 02eec489523f6092ede1bfcbd6ed660ba932354c
}
