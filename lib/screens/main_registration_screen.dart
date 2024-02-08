import 'package:chat_me/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/screens/registration_part_one.dart';
import 'package:chat_me/screens/registration_part_two.dart';

// This widget represents the main registration screen of the chat application.
class MainRegistrationScreen extends StatefulWidget {
  const MainRegistrationScreen({Key? key}) : super(key: key);

  static const String id = 'main_registration_screen';

  // Creates the mutable state for this widget at a given location in the tree.
  @override
  State<MainRegistrationScreen> createState() => _MainRegistrationScreenState();
}

// This class holds the mutable state for the MainRegistrationScreen widget.
class _MainRegistrationScreenState extends State<MainRegistrationScreen> {
  // Declare the variables to hold the user's registration information.
  late String email;
  late String password;
  late String retypedPassword;
  late String displayName;
  late String? userImagePath;
  late String? base64Image;
  late bool userPickedImage;
  late bool showSpinner;

  // Declare the PageController to control the PageView.
  late PageController _pageController;

  // Initialize the state of the widget.
  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    retypedPassword = '';
    displayName = '';
    userImagePath = null;
    base64Image = null;
    userPickedImage = false;
    showSpinner = false;
    _pageController = PageController(); // Initialize the PageController
  }

  // Define the methods to navigate between the pages of the PageView.
  void goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void goToPreviousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Define the methods to update the user's registration information.
  void updateUserImage(String? path, String? base64, bool pickedImage) {
    setState(() {
      userImagePath = path;
      base64Image = base64;
      userPickedImage = pickedImage;
    });
  }

  void updateUserInfo(String email, String password, String retypedPassword,
      String displayName) {
    setState(() {
      this.email = email;
      this.password = password;
      this.retypedPassword = retypedPassword;
      this.displayName = displayName;
    });
  }

  void toggleSpinner(bool toggle) {
    setState(() {
      showSpinner = toggle;
    });
  }

  void updateDisplayName(String name) {
    setState(() {
      displayName = name;
    });
  }

  // Add this function to handle the AppBar's leading IconButton action
  void onLeadingIconPressed() {
    if (_pageController.hasClients) {
      int currentPage = _pageController.page!.round();

      if (currentPage == 0) {
        // If on RegistrationPartOne, navigate to WelcomeScreen
        Navigator.pop(
            context); // Assuming popping this screen takes you back to the WelcomeScreen
      } else if (currentPage == 1) {
        // If on RegistrationPartTwo, navigate back to RegistrationPartOne
        goToPreviousPage();
      }
    }
  }

  // Dispose the PageController when the widget is removed from the widget tree.
  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller
    super.dispose();
  }

  // This method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onLeadingIconPressed,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping
            children: [
              RegistrationPartOne(
                updateUserImage: updateUserImage,
                updateDisplayName: updateDisplayName, // Pass this function
                goToNextPage: goToNextPage, // Pass this function
              ),
              RegistrationPartTwo(
                email: email,
                password: password,
                retypedPassword: retypedPassword,
                displayName: displayName,
                userImagePath: userImagePath,
                base64Image: base64Image,
                userPickedImage: userPickedImage,
                updateUserInfo: updateUserInfo,
                toggleSpinner: toggleSpinner,
                goToPreviousPage: goToPreviousPage,
              ),
            ],
          ),
          if (showSpinner)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.5), // Semi-transparent overlay
                child: const Center(
                  child: CircularProgressIndicator(), // Spinner
                ),
              ),
            ),
        ],
      ),
    );
  }
}
