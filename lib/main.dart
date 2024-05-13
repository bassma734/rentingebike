
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_notifiers/registration_controller.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/mqtt_server_client.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'pages/main_page.dart';
import 'pages/registration_page.dart';
import 'services/auth_service.dart';
//import 'services/mqtt_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //final client = MqttServerClient('192.168.0.6', '1883'); // Replace with your broker's address
  //client.connect('flutter_App'); // Replace with a unique client ID
  /*final mqttService = MqttService();
  mqttService.connect('192.168.0.6');*/
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegistrationController()),
      ],
      child: MaterialApp(
        title: 'Renting App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: background,
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                backgroundColor: background,
                titleTextStyle: const TextStyle(
                  color: primary,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w100,
                ),
              ),
        ),
        home: StreamBuilder<User?>(
          stream: AuthService.userStream,
          builder: (context, snapshot) {
            return snapshot.hasData && AuthService.isEmailVerified
                ? const MainPage()
                : const RegistrationPage();
          },
        ),
      ),
    );
  }
}
