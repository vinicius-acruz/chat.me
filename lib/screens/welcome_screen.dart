// Importing necessary Flutter packages and project-specific files for UI and functionality.
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_me/constants.dart'; // Assuming this contains constant values used across the app.
import 'package:chat_me/screens/login_screen.dart';
import 'package:chat_me/screens/main_registration_screen.dart';
import 'package:chat_me/components/rounded_button.dart'; // Custom component for rounded buttons.

// The WelcomeScreen widget, which is a StatefulWidget to allow for dynamic changes based on user interaction or animations.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id =
      'welcome_screen'; // Static constant for the route name.

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// The state class for WelcomeScreen, including animation controllers and state management.
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller; // Controller for animations.
  late Animation animation; // The animation applied to the color transition.

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 1), // Duration of the animation.
      vsync: this, // The ticker provider for the animation.
      upperBound: 1, // Maximum value for the animation controller.
    );

    // Defining a color tween animation from blue to white.

    controller.forward(); // Starts the animation.
  }

  @override
  void dispose() {
    // Disposing the animation controller to release resources.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allows the body to extend behind the AppBar.
      body: Stack(
        children: [
          const BackgroundContainer(), // Custom widget for the background, assumed to be defined elsewhere.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(children: [
                  Hero(
                    tag: 'logo', // Provides a smooth transition for the logo.
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.20, // Logo size as a percentage of screen height.
                      child: Image.asset('images/logo.png'), // The app's logo.
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Stack(
                    alignment:
                        Alignment.center, // Aligns the stroke and filled text.
                    children: <Widget>[
                      // Stroke text style for the app name.
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.6,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 7
                            ..color = const Color.fromRGBO(230, 128, 120, 1),
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText(' CHAT•ME',
                                speed: const Duration(milliseconds: 100),
                                cursor: ''),
                          ],
                        ),
                      ),
                      // Filled text style for the app name.
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText(' CHAT•ME',
                                speed: const Duration(milliseconds: 100),
                                cursor: ''),
                          ],
                        ),
                      ),
                    ],
                  )
                ]),
                const SizedBox(height: 20.0),
                Column(
                  children: [
                    // Rounded button for the login screen navigation.
                    RoundedButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Rounded button for the registration screen navigation.
                    RoundedButton(
                      text: 'Register',
                      onPressed: () {
                        Navigator.pushNamed(context, MainRegistrationScreen.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
