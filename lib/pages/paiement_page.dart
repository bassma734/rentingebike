// scan_qr_code_page.dart
import 'package:flutter/material.dart';
import '../pages/pay.dart';

class PaiementPage extends StatelessWidget {
  const PaiementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click on the botton to pay',
              style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height : 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => const PayPage()));
                }, child: const Text('Pay'),
              )

            
          ],
        ),
    
        
      ),
    );
  }
}