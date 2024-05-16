import 'package:flutter/material.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});
@override
PayPageState createState() => PayPageState();
}
class PayPageState extends State<PayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: const Center(
        child: Text('payment'),
      ) 
    );
  
  
  
  }
}