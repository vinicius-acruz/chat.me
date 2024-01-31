import 'package:chat_me/constants.dart';
import 'package:chat_me/screens/login_screen.dart';
import 'package:chat_me/screens/main_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_me/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      upperBound: 1, // this is default, left just for studying purposes
    );

    animation =
        ColorTween(begin: Colors.blue, end: Colors.white).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const BackgroundContainer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(children: [
                  Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Stack(
                    alignment:
                        Alignment.center, // Make sure the texts are aligned
                    children: <Widget>[
                      // Stroke text
                      DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          letterSpacing: 0.6,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth =
                                7 // Adjust the stroke width to get the desired effect
                            ..color = const Color.fromRGBO(
                                230, 128, 120, 1), // Light pink for the stroke
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              ' CHAT•ME',
                              speed: const Duration(milliseconds: 100),
                              cursor: '',
                            ),
                          ],
                        ),
                      ),
                      // Filled text
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          letterSpacing: 0.6,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // White for the filled text
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              ' CHAT•ME',
                              speed: const Duration(milliseconds: 100),
                              cursor: '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ]),
                const SizedBox(
                  height: 20.0,
                ),
                Column(
                  children: [
                    RoundedButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
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
