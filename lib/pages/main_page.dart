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
        title: const Text('E-bike Renting App'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(217, 101, 191, 236),
          fontSize: 18,
          fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Please click on the station button for rental reservation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Make a reservation",
              icon: FontAwesomeIcons.calendarCheck,
              onPressed: () => goToEbikeListPage(context),
            ),
            const SizedBox(height: 20),
            const Text(
              "Or click on the scan QR code button for the preferred on-site e-bike rental",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Scan QR code",
              icon: FontAwesomeIcons.qrcode,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQRCodePage()),
                );
              },
            ),
            const SizedBox(height: 20),
            if (widget.isReserved)
              CustomButton(
                label: "You have a reservation",
                icon: FontAwesomeIcons.check,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuccessfulConfirmationPage(
                            ebike: SuccessfulConfirmationPageState.ebikemain)),
                  );
                },
              ),
            const Spacer(),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                ),
                child: const Text(
                  "Show Station Location",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400, color: Color.fromARGB(255, 250, 250, 250)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
  const CustomButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: primary,
        ),
      ),
    );
  }
}
