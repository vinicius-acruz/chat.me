import 'package:flutter/material.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_me/screens/main_screen.dart';

// This widget represents the second part of the registration process.
class RegistrationPartTwo extends StatefulWidget {
  // These are the properties of the RegistrationPartTwo widget.
  // They include user details and functions for updating the UI and navigating between pages.
  final String email;
  final String password;
  final String retypedPassword;
  final String displayName;
  final String? userImagePath;
  final String? base64Image;
  final bool userPickedImage;
  final Function(bool) toggleSpinner;
  final Function(String email, String password, String retypedPassword,
      String displayName) updateUserInfo;
  final VoidCallback goToPreviousPage;

  // The constructor for the RegistrationPartTwo widget.
  const RegistrationPartTwo({
    Key? key,
    required this.email,
    required this.password,
    required this.retypedPassword,
    required this.displayName,
    required this.userImagePath,
    required this.base64Image,
    required this.userPickedImage,
    required this.toggleSpinner,
    required this.updateUserInfo,
    required this.goToPreviousPage,
  }) : super(key: key);

  // Creates the mutable state for this widget at a given location in the tree.
  @override
  State<RegistrationPartTwo> createState() => _RegistrationPartTwoState();
}

// This class holds the mutable state for the RegistrationPartTwo widget.
class _RegistrationPartTwoState extends State<RegistrationPartTwo> {
  // Firebase authentication and Firestore instances.
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Variables to hold user details.
  late String email;
  late String password;
  late String retypedPassword;
  late String displayName;

  // Method to get the current context.
  BuildContext getContext() {
    return context;
  }

  // This method is called when this object is inserted into the tree.
  @override
  void initState() {
    super.initState();
    email = widget.email;
    password = widget.password;
    retypedPassword = widget.retypedPassword;
    displayName = widget.displayName;
  }

  // This method handles user registration.
  Future<void> registerUser() async {
    // Check if the passwords match.
    if (password != retypedPassword) {
      CustomDialog.show(
        context: context,
        title: 'Password Mismatch',
        content: 'The entered passwords do not match.',
        bottomButtonColor: Colors.grey,
        bottomButtonText: 'OK',
        bottomButtonTextColor: Colors.white,
      );
      return;
    }
    widget.toggleSpinner(true);
    try {
      // Create a new user with the provided email and password.
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Set the display name
      await newUser.user!.updateDisplayName(displayName);

      // Create a new document to store user information
      await _firestore.collection('users').doc(newUser.user!.email).set({
        'email': email,
        'userId': newUser.user!.uid,
        'userImagePath': widget.userImagePath,
        'base64Image': widget.base64Image,
        'displayName': displayName,
        'userPickedImage': widget.userPickedImage,
      });

      // Show a success dialog and navigate to the main screen.
      CustomDialog.show(
        context: getContext(),
        title: 'Registration Successful!',
        content: 'Start chatting!',
        onOkPressed: () {
          Navigator.pushNamed(context, MainScreen.id);
        },
        bottomButtonColor: Colors.grey,
        bottomButtonText: 'Proceed',
      );

      widget.toggleSpinner(false);
    } catch (e) {
      // Show an error dialog if registration fails.
      String errorMessage = e.toString();

      CustomDialog.show(
        context: getContext(),
        title: 'Registration Error',
        content: errorMessage,
        bottomButtonColor: Colors.grey,
        bottomButtonText: 'Try again',
        bottomButtonTextColor: Colors.grey,
      );
      widget.toggleSpinner(false);
    }
  }

  // This method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.20),
        // Text fields for email and password input.
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter your e-mail',
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: TextField(
            obscureText: true,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Type your password',
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: TextField(
            obscureText: true,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                retypedPassword = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Retype your password',
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        // Registration button.
        RoundedButton(
          text: 'Register',
          onPressed: () async {
            // Before calling registerUser, ensure to update the MainRegistrationScreen's state with the latest values
            widget.updateUserInfo(email, password, retypedPassword,
                displayName); // Update the state in MainRegistrationScreen
            registerUser(); //
          },
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
