import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/screens/welcome_screen.dart';
import 'package:chat_me/components/user_info_widget.dart'; // Custom widget to display user information.

// SettingsScreen widget is a StatefulWidget to manage user settings.
class SettingsScreen extends StatefulWidget {
  static const String id =
      'settings_screen'; // Static constant for the route name.

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// State class for SettingsScreen.
class _SettingsScreenState extends State<SettingsScreen> {
  // Firebase Firestore and Auth instance for database and authentication operations.
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // TextEditingControllers to manage the input fields for user data.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _reAuthPasswordController = TextEditingController();

  // Boolean to track if the user is editing their password and loading state.
  bool _isEditingPassword = false;
  String passwordPlaceholder =
      '********'; // Placeholder text for the password field.
  bool _isLoading = false;

  // Helper method to get the current build context.
  BuildContext getContext() {
    return context;
  }

  @override
  void initState() {
    super.initState();
    // Initialize the input fields with the current user's information if available.
    final user = _auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      _displayNameController.text = user.displayName ?? "";
    }
    _passwordController.text = passwordPlaceholder;
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources.
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _reAuthPasswordController.dispose();
    super.dispose();
  }

  // Method to re-authenticate the user, required for certain sensitive operations like updating email or password.
  Future<void> _reAuthenticateUser() async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (email != null && _reAuthPasswordController.text.isNotEmpty) {
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: _reAuthPasswordController.text,
        );
        await user?.reauthenticateWithCredential(credential);
        _updateUserInfo(); // Proceed to update user information after successful re-authentication.
      } catch (e) {
        // Display error message if re-authentication fails.
        ScaffoldMessenger.of(getContext()).showSnackBar(
          SnackBar(content: Text("Error re-authenticating user: $e")),
        );
      }
    }
  }

  // Method to update user information in Firebase Auth and Firestore.
  Future<void> _updateUserInfo() async {
    setState(() {
      _isLoading = true; // Show loading indicator during the update operation.
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update email if it has changed.
        if (_emailController.text.isNotEmpty &&
            _emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text);
          // Optionally, update the email in Firestore if it's used as a key or reference.
          await _firestore.collection('users').doc(user.email).update({
            'email': _emailController.text,
          });
        }

        // Update password if the field has been edited and doesn't contain the placeholder text.
        if (_passwordController.text.isNotEmpty &&
            _passwordController.text != passwordPlaceholder) {
          await user.updatePassword(_passwordController.text);
        }

        // Update display name if it has changed.
        if (_displayNameController.text.isNotEmpty &&
            _displayNameController.text != user.displayName) {
          await user.updateDisplayName(_displayNameController.text);
          // Optionally, update the display name in Firestore.
          await _firestore.collection('users').doc(user.email).update({
            'displayName': _displayNameController.text,
          });
        }

        // Hide loading indicator and show success message.
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(getContext()).showSnackBar(const SnackBar(
          content: Text("User information updated successfully!"),
          duration: Duration(seconds: 1),
        ));
      }
    } catch (e) {
      // Handle specific errors like 'requires-recent-login' by prompting re-authentication.
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        // Prompt for re-authentication.
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
                    Navigator.of(context).pop(); // Close the dialog.
                    _reAuthenticateUser(); // Attempt to re-authenticate.
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      } else {
        // Display error message for other update failures.
        ScaffoldMessenger.of(getContext()).showSnackBar(
          SnackBar(content: Text("Error updating user information: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in before showing settings.
    final loggedInUser = _auth.currentUser;
    if (loggedInUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserInfoWidget(
                loggedInUser:
                    loggedInUser), // Custom widget to display user info.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  // Input fields for user email, password, and display name with edit icons.
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
                    obscureText: !_isEditingPassword,
                    onTap: () {
                      // Enable editing mode for password.
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
                  // Show loading indicator or save changes button based on _isLoading state.
                  _isLoading
                      ? const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()))
                      : RoundedButton(
                          onPressed: _updateUserInfo,
                          text: 'Save Changes',
                        ),
                  const SizedBox(height: 20),
                  // Logout button that signs out the user and navigates back to the welcome screen.
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
