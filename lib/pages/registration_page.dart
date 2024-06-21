import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../change_notifiers/registration_controller.dart';
import '../core/constants.dart';
import '../core/validator.dart';
import '../widgets/note_button.dart';
import '../widgets/note_form_field.dart';
import 'recover_password_page.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final RegistrationController registrationController;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController phoneController; // New controller for phone number
  late final GlobalKey<FormState> formKey;

  String pageTitle = 'Register'; // Add a title state variable

  @override
  void initState() {
    super.initState();
    registrationController = context.read<RegistrationController>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController(); // Initialize phone controller
    formKey = GlobalKey();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose(); // Dispose phone controller
    super.dispose();
  }

  void updateTitle() {
    setState(() {
      pageTitle =
          registrationController.isRegisterMode ? 'Register' : 'Sign in'; // Update title based on mode
    });
  }

  /*void _registerUser() {
    if (formKey.currentState!.validate()) {
      registrationController.registerUser(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneController.text.trim(), // Pass phone number to registration
      );

      // Optionally, you can clear the form fields after registration
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneController.clear(); // Clear phone number field
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, Color.fromARGB(96, 3, 168, 244)],
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
              'RentCycle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(13, 3, 168, 244)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        pageTitle, // Use the state variable for the title
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'In order to rent an e-bike, you have to register/sign in to the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 48),
                      if (registrationController.isRegisterMode)

                      NoteFormField(
                        controller: nameController,
                        labelText: 'Full name',
                        fillColor: Colors.white,
                        filled: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        validator: Validator.nameValidator,
                        onChanged: (newValue) {
                          registrationController.fullName = newValue;
                        },
                      ),
                      const SizedBox(height: 8),
                      NoteFormField(
                        controller: emailController,
                        labelText: 'Email address',
                        fillColor: Colors.white,
                        filled: true,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validator.emailValidator,
                        onChanged: (newValue) {
                          registrationController.email = newValue;
                        },
                      ),
                      const SizedBox(height: 8),
                      NoteFormField(
                        controller: passwordController,
                        labelText: 'Password',
                        fillColor: Colors.white,
                        filled: true,
                        obscureText: true,
                        validator: Validator.passwordValidator,
                        onChanged: (newValue) {
                          registrationController.password = newValue;
                        },
                      ),
                      const SizedBox(height: 8),
                      NoteFormField(
                        controller: phoneController,
                        labelText: 'Phone number',
                        fillColor: Colors.white,
                        filled: true,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          registrationController.phoneNumber = newValue;
                        },
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RecoverPasswordpage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: Selector<RegistrationController, bool>(
                          selector: (_, controller) => controller.isLoading,
                          builder: (_, isLoading, __) => NoteButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ?? false) {
                                      registrationController.authenticateWithEmailAndPassword(context: context);
                                    }                              
                                        },
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    registrationController.isRegisterMode
                                        ? 'Create my account'
                                        : 'Sign in',
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Or register with',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                registrationController
                                    .authenticateWithGoogle(context: context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black, backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                elevation: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_logo.png',
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Sign in with Google',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text.rich(
                        TextSpan(
                          text: registrationController.isRegisterMode
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                          style: const TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: registrationController.isRegisterMode
                                  ? 'Sign in'
                                  : 'Register',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    registrationController.isRegisterMode =
                                        !registrationController.isRegisterMode;
                                    updateTitle(); // Update the title when mode changes
                                  });
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
