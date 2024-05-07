import 'package:renting_app/pages/ebike_list_page.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/dialogs.dart';
import '../services/auth_service.dart';
import '../widgets/note_icon_button_outlined.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike Renting',),
  
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
            const SizedBox(height: 50),
            const Text("Welcome ",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
            const SizedBox(height: 50),
            const Text(
              "Please click on the station to see our e-bikes",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Add your station widget here
            // For example:
            CustomButton(
              label: "Station",
              onPressed: () => goToEbikeListPage(context),
              ),
            const Spacer()
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
        builder: (_) => const EbikeListPage(),
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
    width: 280, // adjust the size as needed
    height: 280, // adjust the size as needed
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 60), // adjust the border color and width as needed
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 30 ,fontWeight: FontWeight.w300),
        ),
        
      ),
    ),
  );
}

}
  
   