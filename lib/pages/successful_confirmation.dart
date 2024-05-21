 import 'package:flutter/material.dart';
import 'package:renting_app/pages/scan_qr_code_res.dart';
//import 'reservation_form_page.dart';
import '../pages/ebike_model.dart';
import '../core/constants.dart';


class SuccessfulConfirmationPage extends StatelessWidget {
  final Ebike ebike ;

  const SuccessfulConfirmationPage({  required this.ebike ,super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Successful Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/confirmation_icon.png', // Path to your image asset
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),


            const Text(
              'Your reservation has been confirmed successfully.',
              style: TextStyle(fontSize: 25 ) , textAlign: TextAlign.center,
            ),
            const SizedBox(height : 50), 
            const Text(
              'Scan the QR code when you get there.',
              style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 0, 152, 167),fontWeight: FontWeight.w500),
            ),
            const SizedBox(height : 35),

            SizedBox(
              width : 200, // adjust the size as needed
              height : 80, // adjust the size as needed
    
              child:ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanQRCodeResPage(ebike : ebike),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1, color: Color.fromARGB(255, 5, 13, 20)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Text('Scan QR Code',style: TextStyle(fontSize: 20,color: black),),
            ),),

            const SizedBox(height : 45),

            SizedBox(
              width : 200, // adjust the size as needed
              height : 50, // adjust the size as needed
    
              child:ElevatedButton(
                onPressed: () {} ,
                 /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanQRCodeResPage(ebike : ebike),
                  ),
                );
              },*/
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1, color: Color.fromARGB(255, 180, 185, 191)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Text('Cancel reservation',style: TextStyle(fontSize: 14,color: black),),
            ),)
          ],
        ),
      ),
    );
  }
}