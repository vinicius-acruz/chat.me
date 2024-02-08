// Importing necessary Dart packages and files for the project.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_me/screens/welcome_screen.dart';
import 'package:chat_me/screens/login_screen.dart';
import 'package:chat_me/screens/chat_screen.dart';
import 'package:chat_me/screens/contacts_screen.dart';
import 'package:chat_me/screens/inbox_screen.dart';
import 'package:chat_me/screens/main_registration_screen.dart';
import 'package:chat_me/screens/main_screen.dart';
import 'package:chat_me/screens/splash_screen.dart';
import 'package:chat_me/components/user.dart'; // Custom user component for handling user data.
import 'firebase_options.dart'; // Importing Firebase configuration settings.

// The main entry point of the Flutter application.
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter engine is initialized.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Initialize Firebase with the default options for the current platform.
  );

  runApp(const ChatMe()); // Running the ChatMe app.
}

// The ChatMe class which is a StatelessWidget that represents the whole app.
class ChatMe extends StatelessWidget {
  const ChatMe({Key? key})
      : super(key: key); // Constructor for the ChatMe class.

  @override
  Widget build(BuildContext context) {
    // Building the MaterialApp with necessary configurations.
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Removes the debug banner from the app.
      initialRoute: SplashScreen.id, // Sets the initial route to SplashScreen.
      routes: {
        // Defining routes for the app. Each route is identified by an id and maps to a specific screen.
        SplashScreen.id: (context) => const SplashScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        MainScreen.id: (context) => const MainScreen(),
        ContactsScreen.id: (context) => const ContactsScreen(),
        InboxScreen.id: (context) => InboxScreen(),
        MainRegistrationScreen.id: (context) => const MainRegistrationScreen(),
      },
      onGenerateRoute: (settings) {
        // Handling named routes dynamically, especially for routes that require arguments.
        if (settings.name == ChatScreen.id) {
          final args = settings.arguments
              as UserData; // Casting the arguments to the expected type (UserData).
          return MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                  user: args); // Passing the arguments to the ChatScreen.
            },
          );
        }
        // Return null for any unhandled routes, which allows the app to fall back to the route configuration.
        return null;
      },
    );
  }
}
