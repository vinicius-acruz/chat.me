import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_me/components/user_info_widget.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _reAuthPasswordController = TextEditingController();
  bool _isEditingPassword = false; // Track if user is editing password
  String passwordPlaceHolder = '********';
  bool _isLoading = false;

  BuildContext getContext() {
    return context;
  }

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      _displayNameController.text = user.displayName ?? "";
    }
    _passwordController.text =
        passwordPlaceHolder; // Placeholder for the password field
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _reAuthPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reAuthenticateUser() async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (email != null && _reAuthPasswordController.text.isNotEmpty) {
      try {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: email,
          password: _reAuthPasswordController.text,
        );
        await user?.reauthenticateWithCredential(credential);
        _updateUserInfo(); // Call update user info if re-authentication is successful
      } catch (e) {
        ScaffoldMessenger.of(getContext()).showSnackBar(
          SnackBar(content: Text("Error re-authenticating user: $e")),
        );
      }
    }
  }

  Future<void> _updateUserInfo() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
// Update email
        if (_emailController.text.isNotEmpty &&
            _emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
          // Also update the Firestore document reference if you use email as document ID
          await _firestore.collection('users').doc(user.email).update({
            'email': _emailController.text,
          });
        }

        // Update password only if it's not the placeholder
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text != passwordPlaceHolder) {
          await user.updatePassword(_passwordController.text);
        }

        // Update display name
        if (_displayNameController.text.isNotEmpty &&
            _displayNameController.text != user.displayName) {
          await user.updateDisplayName(_displayNameController.text);
          // Also update the Firestore document reference
          await _firestore.collection('users').doc(user.email).update({
            'displayName': _displayNameController.text,
          });
        }
        setState(() {
          _isLoading = false; // Set loading to true
        });

        ScaffoldMessenger.of(getContext()).showSnackBar(const SnackBar(
          content: Text("User information updated successfully!"),
          duration: Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        // Show re-authentication dialog
        showDialog(
          context: getContext(),
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Re-authentication required"),
              content: TextField(
                controller: _reAuthPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Enter your current password',
                ),
                obscureText: true,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _reAuthenticateUser(); // Re-authenticate user
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(getContext()).showSnackBar(
          SnackBar(content: Text("Error updating user information: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = _auth.currentUser;
    if (loggedInUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0), // Add padding to avoid AppBar
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserInfoWidget(loggedInUser: loggedInUser),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      suffixIcon: Icon(Icons.edit),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Leave blank to keep the same',
                      suffixIcon: Icon(Icons.edit),
                    ),
                    obscureText: !_isEditingPassword, // Modify this line
                    onTap: () {
                      // Clear the text field and set state to editing when the user taps the field
                      if (!_isEditingPassword) {
                        setState(() {
                          _passwordController.clear();
                          _isEditingPassword = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : RoundedButton(
                          onPressed: _updateUserInfo,
                          text: 'Save Changes',
                        ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pushNamed(context, WelcomeScreen.id);
                    },
                    text: 'Log out',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
