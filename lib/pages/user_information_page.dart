// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renting_app/pages/main_page.dart';
import '../services/firestore_service.dart';
import '../pages/rental_history_page.dart';
import '../core/constants.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  String _originalName = '';
  String _originalEmail = '';
  

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    var userInfo = await _firestoreService.getUserInfo();
    if (userInfo.exists) {
      var userData = userInfo.data() as Map<String, dynamic>;
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _originalName = _nameController.text;
      _originalEmail = _emailController.text;
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      MainPageState.selectedIndex = index;
    });
    switch (index) {
      case 0:
        const UserInfoPage();
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RentalHistoryPage()),
          (Route<dynamic> route) => false,
        );
        break;
    }
  }

  Future<void> _updateName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
        setState(() {
          _originalName = _nameController.text;
          _isEditingName = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? email = user.email;
      if (email != null) {
        try {
          // Re-authenticate the user
          final AuthCredential credential = EmailAuthProvider.credential(email: email, password: 'your-password'); // Use the correct password here
          await user.reauthenticateWithCredential(credential);
          
          // Update the email
          await user.verifyBeforeUpdateEmail(_emailController.text);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'email': _emailController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email updated successfully')),
          );
          setState(() {
            _originalEmail = _emailController.text;
            _isEditingEmail = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _changePassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _originalEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildNameField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: _isEditingName
            ? TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your name',
                ),
              )
            : Text(_originalName),
        trailing: IconButton(
          icon: Icon(_isEditingName ? Icons.check : Icons.edit),
          onPressed: () {
            if (_isEditingName) {
              _updateName();
            } else {
              setState(() {
                _isEditingName = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(Icons.email),
        title: _isEditingEmail
            ? TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
              )
            : Text(_originalEmail),
        trailing: IconButton(
          icon: Icon(_isEditingEmail ? Icons.check : Icons.edit),
          onPressed: () {
            if (_isEditingEmail) {
              _updateEmail();
            } else {
              setState(() {
                _isEditingEmail = true;
              });
            }
          },
        ),
      ),
    );
  }

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
        title: const Text('Personal Informations',style: TextStyle(color: white),),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, Color.fromARGB(12, 137, 178, 197)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: _firestoreService.getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No user information found'));
            } else {
              return ListView(
                children: [
                  _buildNameField(),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: primary,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Rental History',
          ),
        ],
        currentIndex: MainPageState.selectedIndex,
        selectedItemColor: primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
