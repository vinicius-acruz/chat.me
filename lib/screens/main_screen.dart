import 'package:flutter/material.dart';
import 'inbox_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart'; // import the settings screen

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';

  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    InboxScreen(),
    const ContactsScreen(),
    const SettingsScreen(), // Add the settings screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            false, // Change title based on the selected index
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
