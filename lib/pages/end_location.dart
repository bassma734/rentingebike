
import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../pages/pay.dart';

class EndLocation extends StatefulWidget {
  final double amount;

  const EndLocation({super.key, required this.amount});

  @override
  EndLocationState createState() => EndLocationState();
}

class EndLocationState extends State<EndLocation> {
  final _paymentService = PaymentService();
  
  void _startPayment() async {

    try {
      final paymentUrl = await _paymentService.createPayment(
       widget.amount , 'bassma', 'rh', 'bessa@gmail.com', '+21622334455',
      );

      if (paymentUrl != null) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => PaymentPage(paymentUrl: paymentUrl)),
        );
      }
    } catch (e) {
      debugPrint('Payment creation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('end location page '),
      ),
      body: Center(
        

        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Text('Your session has ended. Please proceed to payment to complete your transaction.', ),
           ElevatedButton(
             onPressed: _startPayment,
             child: const Text('proceed to pay '),
            ),]
      ),)
    );
  }
}

