import 'package:flutter/material.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_me/screens/main_screen.dart';

class RegistrationPartTwo extends StatefulWidget {
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

  @override
  State<RegistrationPartTwo> createState() => _RegistrationPartTwoState();
}

class _RegistrationPartTwoState extends State<RegistrationPartTwo> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late String email;
  late String password;
  late String retypedPassword;
  late String displayName;

  BuildContext getContext() {
    return context;
  }

  @override
  void initState() {
    super.initState();
    email = widget.email;
    password = widget.password;
    retypedPassword = widget.retypedPassword;
    displayName = widget.displayName;
  }

  Future<void> registerUser() async {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.20),
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
