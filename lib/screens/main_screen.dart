import 'package:flutter/material.dart';
import 'inbox_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart'; // import the settings screen

// This widget represents the main screen of the chat application.
class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';

  const MainScreen({super.key});

  // Creates the mutable state for this widget at a given location in the tree.
  @override
  MainScreenState createState() => MainScreenState();
}

// This class holds the mutable state for the MainScreen widget.
class MainScreenState extends State<MainScreen> {
  // The index of the currently selected widget in the bottom navigation bar.
  int _selectedIndex = 0;

  // The list of widgets to display when a bottom navigation bar item is selected.
  final List<Widget> _widgetOptions = [
    InboxScreen(),
    const ContactsScreen(),
    const SettingsScreen(), // Add the settings screen
  ];

  // This method is called when a bottom navigation bar item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      "Inbox",
      "Contacts",
      "Settings"
    ]; // Add titles for the AppBar

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(color: Colors.black54),
        ),
        backgroundColor: const Color.fromRGBO(250, 106, 106, 1),
        automaticallyImplyLeading:
            false, // Remove the back button from the app bar
      ),
      backgroundColor: const Color.fromRGBO(247, 243, 238, 1),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(250, 106, 106, 1),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
