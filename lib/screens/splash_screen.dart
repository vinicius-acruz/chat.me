// Importing necessary Flutter packages and project-specific files for UI and functionality.
import 'package:flutter/material.dart';
import 'package:chat_me/screens/welcome_screen.dart';
import 'package:chat_me/constants.dart';

// SplashScreen widget which is a StatefulWidget to manage its animation state.
class SplashScreen extends StatefulWidget {
  const SplashScreen(
      {super.key}); // Constructor with an optional key parameter.

  static const String id =
      'splash_screen'; // Static constant for the route name.

  @override
  SplashScreenState createState() => SplashScreenState();
}

// State class for SplashScreen with SingleTickerProviderStateMixin for animation control.
class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController
      _controller; // Controller for the splash screen animation.
  late Animation<double>
      _animation; // Animation variable to manage the opacity.

  @override
  void initState() {
    super.initState();

    // Initializing the animation controller with a specified duration.
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Defining a tween animation that changes from 0 to 1.
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(
            () {}); // Triggering a rebuild whenever the animation value changes.
      });

    // Once the animation has completed, navigate to the main screen.
    _controller.forward().then((value) => _navigateToMainScreen());
  }

  // Function to navigate to the main screen with a custom page transition.
  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const WelcomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Using a FadeTransition for navigating to the WelcomeScreen.
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration:
          const Duration(seconds: 1), // Duration of the fade transition.
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Calculating the logo size as a percentage of the screen height.
    final logoSize = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundContainer(), // Custom widget for the background, assumed to be defined elsewhere.
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Displaying the app logo with an animation.
                Image.asset(
                  'images/logo.png',
                  width: logoSize *
                      _animation
                          .value, // Animated width based on the animation value.
                  height: logoSize *
                      _animation
                          .value, // Animated height based on the animation value.
                ),
                const SizedBox(
                  height: 200, // Spacing after the logo.
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Disposing the animation controller to release resources.
    _controller.dispose();
    super.dispose();
  }
}
