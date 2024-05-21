import 'package:flutter/material.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: const Center(
        child: Text(
          'Payment Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
