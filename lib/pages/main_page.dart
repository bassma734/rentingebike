import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:renting_app/pages/ebike_list_page.dart';
import 'package:renting_app/pages/map_page.dart';
import 'package:renting_app/pages/scan_qr_code_onsite.dart';
import 'package:renting_app/pages/successful_confirmation.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../services/auth_service.dart';
//import '../widgets/note_icon_button_outlined.dart';

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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, Color.fromARGB(80, 3, 168, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_bike, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'E-bike Renting App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final bool shouldLogout = await showConfirmationDialog(
                context: context,
                title: 'Do you want to sign out of the app?',
              ) ?? false;
              if (shouldLogout) AuthService.logout();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Welcome ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary, // Adjusted color to primary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Please click on the station button for rental reservation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildFeatureCard(
              icon: FontAwesomeIcons.bicycle,
              title: "Make a Reservation",
              subtitle: "Reserve your e-bike at a nearby station",
              onTap: () => goToEbikeListPage(context),
            ),
            const SizedBox(height: 20),
          
            _buildFeatureCard(
              icon: FontAwesomeIcons.qrcode,
              title: "Scan QR Code",
              subtitle: "Scan the QR code for on-site rental",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanQRCodePage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Conditionally rendering the "Your Reservation" button
            if (widget.isReserved)
              _buildFeatureCard(
                icon: FontAwesomeIcons.clipboardCheck,
                title: "Your Reservation",
                subtitle: "View your current reservation status",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuccessfulConfirmationPage(
                            ebike: SuccessfulConfirmationPageState.ebikemain)),
                  );
                },
              ),
            if (widget.isReserved)
              const SizedBox(height: 20),

            _buildFeatureCard(
              icon: FontAwesomeIcons.locationDot,
              title: "Show Station Location",
              subtitle: "View the location of nearby stations",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              isPrimary: true,
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [primary, Color.fromARGB(112, 3, 168, 244)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isPrimary ? Colors.transparent : Colors.black12,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor:
                    isPrimary ? Colors.white24 : primary.withOpacity(0.2),
                child: FaIcon(icon,
                    size: 20, color: isPrimary ? Colors.white : primary),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isPrimary ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPrimary)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
