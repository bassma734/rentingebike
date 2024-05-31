//import 'package:flutter/widgets.dart';
import 'package:renting_app/pages/ebike_list_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:renting_app/pages/scan_qr_code_onsite.dart';
import 'package:renting_app/pages/map_page.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../services/auth_service.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../pages/successful_confirmation.dart';

class MainPage extends StatefulWidget {
  final bool isReserved;
  const MainPage({super.key, required this.isReserved});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-bike Renting App',
        ),
        titleTextStyle: const TextStyle(
          color: primary,
          fontSize: 18,
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
      body:
          Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Welcome ",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            const Text(
              "Please click on the station button for rental reservation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Make a reservation",
              onPressed: () => goToEbikeListPage(context),
            ),
            const SizedBox(height: 70),
            const Text(
              "or click on the scan QR code button for the preferred on-site e-bike rental ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 90,
              width: 230,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanQRCodePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 0, color: Color.fromARGB(255, 16, 18, 19)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  backgroundColor: primary,
                ),
                child: const Text(
                  "Scan QR code",
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w100, color: black),
                ),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              height: 40,
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuccessfulConfirmationPage(
                            ebike: SuccessfulConfirmationPageState.ebikemain)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 0, color: Color.fromARGB(255, 5, 13, 20)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color.fromARGB(46, 60, 134, 199),
                ),
                child: const Text(
                  "You have a reservation",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w200, color: black),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MapPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                ),
                child: const Text(
                  "Show Station Location",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
  }

  void goToEbikeListPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EbikeListPage(isReserved: widget.isReserved),
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
      width: 280,
      height: 110,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          side: const BorderSide(
              width: 0, color: Color.fromARGB(255, 5, 13, 20)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
          backgroundColor: primary,
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 27, fontWeight: FontWeight.w300, color: black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
