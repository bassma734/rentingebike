//import 'package:flutter/widgets.dart';
import 'package:renting_app/pages/ebike_list_page.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:renting_app/pages/scan_qr_code_onsite.dart';
import '../core/dialogs.dart';
import '../services/auth_service.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../pages/successful_confirmation.dart';


class MainPage extends StatefulWidget {
   final bool isReserved  ;
  const MainPage({super.key , required this.isReserved});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike Renting App',),
        titleTextStyle: const TextStyle(
                  color: primary,
                  fontSize: 18,
                  //fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
  
        actions: [
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.rightFromBracket,
            onPressed: () async {
              final bool shouldLogout = await showConfirmationDialog(
                    context: context,
                    title: 'Do you want to sign out of the app?',
                  ) ??
                  false;
              if (shouldLogout) AuthService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height : 50),
            const Text("Welcome ",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
            const SizedBox(height : 50),
            const Text(
              "Please click on the station button for rental reservation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height :30),
            // Add your station widget here
            // For example:
            CustomButton(
              label: "Make a reservation",
              onPressed: () => goToEbikeListPage(context),
              ),
            const SizedBox(height :70),
            const Text(
              "or click on the scan QRcode button for the preffered on-site e-bike rental ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height :40),
            SizedBox(
              height : 90,
              width :230,
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQRCodePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width : 0, color: Color.fromARGB(255, 16, 18, 19)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), // border radius
                  backgroundColor: primary,
                ),
<<<<<<< HEAD
                child: const Text("Scan QR code" , style: TextStyle(fontSize: 25,fontWeight:FontWeight.w300 , color: black)),
=======
                child: const Text("Scan QR code" , style: TextStyle(fontSize: 25,fontWeight:FontWeight.w100 , color: black)),
              ),
            ),
            const SizedBox(height :60),

            SizedBox(
              height : 40,
              width :300,
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuccessfulConfirmationPage(ebike: SuccessfulConfirmationPageState.ebikemain)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 0, color: Color.fromARGB(255, 5, 13, 20)), // border color and width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // border radius
                  backgroundColor: const Color.fromARGB(46, 60, 134, 199),
                ),
                child: const Text("you have a reservation" , style: TextStyle(fontSize: 18,fontWeight:FontWeight.w200 , color: black)),
>>>>>>> c47fa3dff5dee4340f643d35f9d3fe3ece33a5b1
              ),
            ),

          ],
        ),
      ),
    );
  }

  goToEbikeListPage(BuildContext context) {
    // Navigate to the station details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>   EbikeListPage(isReserved : widget.isReserved ),
        ),
    );
  }


}
      
class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.label, this.onPressed});
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width : 280, // adjust the size as needed
    height : 110, // adjust the size as needed
    
      child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
       side: const BorderSide(width : 0, color: Color.fromARGB(255, 5, 13, 20)), // border color and width
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), // border radius
        backgroundColor: primary,
      ),
      
      child: Text(
        label,
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w300, color: black),
        textAlign: TextAlign.center,
      ),
    ),
  
  );
}

}