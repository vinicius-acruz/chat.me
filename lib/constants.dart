import 'package:flutter/material.dart';

const kMessageContainerColor = Colors.white;

const kSendButtonTextStyle = TextStyle(
  color: Colors.black54,
  fontWeight: FontWeight.w600,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

// Define a BoxDecoration for the message container
BoxDecoration kMessageContainerDecoration = const BoxDecoration(
  color: kMessageContainerColor,
  border: Border(
    top: BorderSide(color: Colors.grey, width: 2.0),
  ),
);

// Define a InputDecoration for the TextField
InputDecoration kTextFieldDecoration = const InputDecoration(
  hintText: 'Enter your message here...',
  hintStyle: TextStyle(color: Colors.black54),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
    borderSide: BorderSide.none, // No border
  ),
  filled: true,
  fillColor: Colors.white, // Fill color for the TextField
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

// BackgroundContainer Color Palette

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        // take all the available space
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.5,
            center: Alignment(0.3, -0.5),
            colors: [
              Color.fromRGBO(250, 197, 101, 1), // Peach
              Color.fromRGBO(245, 187, 146, 1), // Beige
              Color.fromRGBO(245, 160, 190, 1), // Pink
              Color.fromRGBO(250, 106, 106, 1), // Coral
            ],
          ),
        ),
      ),
    );
  }
}

// AppBar Color Palette

const kAppBarColor = Color.fromRGBO(250, 106, 106, 1); // Peach