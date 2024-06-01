import 'package:flutter/material.dart';
import 'package:renting_app/pages/main_page.dart';
import 'package:renting_app/pages/scan_qr_code_res.dart';
//import 'reservation_form_page.dart';
import '../pages/ebike_model.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';



class SuccessfulConfirmationPage extends StatefulWidget {
  final Ebike ebike ;

  const SuccessfulConfirmationPage({  required this.ebike ,super.key});
  
  
  @override
  SuccessfulConfirmationPageState createState() => SuccessfulConfirmationPageState();}

class SuccessfulConfirmationPageState extends State <SuccessfulConfirmationPage>{
  bool state = true ;
  
static  Ebike ebikemain =Ebike(name:' name', photo :'assets/images/Ebike.jpeg',) ;
  get ebike => widget.ebike;


 

  
  @override
  Widget build(BuildContext context) {
    ebikemain = widget.ebike ;
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
              width : 100,
              height : 100,
            ),
            const SizedBox(height : 20),


            Text(
              'Your ${ebike.name} reservation has been confirmed successfully.',
              style: const TextStyle(fontSize: 25 ) , textAlign: TextAlign.center,
            ),
            const SizedBox(height : 40), 
            const Text(
              'Scan the QR code when you get there.',
              style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 106, 168, 201),fontWeight: FontWeight.w500),
            ),
            const SizedBox(height : 35),

            SizedBox(
              width : 200, // adjust the size as needed
              height : 50, // adjust the size as needed
    
              child:ElevatedButton(
                onPressed: () {
                  setState(() {
                      state  = false ;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanQRCodeResPage(ebike : widget.ebike),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width : 0, color: Color.fromARGB(255, 5, 13, 20)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Text('Scan QR Code',style: TextStyle(fontSize: 20,color: black),),
            ),),

            const SizedBox(height : 45),

            SizedBox(
              width : 200, // adjust the size as needed
              height : 40, // adjust the size as needed
    
              child:ElevatedButton(
                onPressed: () async {
                  setState(() {
                      state  = false ;
                  });

                  final bool cancel = await showConfirmationDialog(
                    context: context,
                    title: 'Do you want to cancel your reservation?',
                  ) ??
                  false;
                  if (cancel) {
                    Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  MainPage(isReserved : state ),
                  ),
                );}

                } ,
              
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width : 0, color: Color.fromARGB(255, 6, 6, 6)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Text('Cancel reservation',style: TextStyle(fontSize: 14,color: black),),
            ),),

const SizedBox(height : 45),

            SizedBox(
              width : 70, // adjust the size as needed
              height : 50, 
            child:ElevatedButton(
                onPressed: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  const MainPage(isReserved : true ),
                  ),
                );

                } ,
              
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width : 0, color: Color.fromARGB(255, 0, 0, 0)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: gray100,
                ),
              child: const Icon(Icons.home, size: 20, color: primary),
            ),) 


          ],
        ),
      ),
    );
  }
}