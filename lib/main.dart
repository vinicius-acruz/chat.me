import 'package:chat_me/components/user.dart';
import 'package:chat_me/screens/contacts_screen.dart';
import 'package:chat_me/screens/inbox_screen.dart';
import 'package:chat_me/screens/main_registration_screen.dart';
import 'package:chat_me/screens/main_screen.dart';
import 'package:chat_me/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/screens/welcome_screen.dart';
import 'package:chat_me/screens/login_screen.dart';
import 'package:chat_me/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChatMe());
}

class ChatMe extends StatelessWidget {
  const ChatMe({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        MainScreen.id: (context) => const MainScreen(),
        ContactsScreen.id: (context) => const ContactsScreen(),
        InboxScreen.id: (context) => InboxScreen(),
        MainRegistrationScreen.id: (context) => const MainRegistrationScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle named routes
        if (settings.name == ChatScreen.id) {
          final args = settings.arguments
              as UserData; // Cast the arguments to the expected type.
          return MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                  user: args); // Pass the arguments to the ChatScreen.
            },
          );
        }

        return null; // Implement other routes as needed or return null.
      },
    );
  }
}
