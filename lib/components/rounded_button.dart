import 'package:flutter/material.dart';
import 'dart:async'; // Import the dart:async package

class RoundedButton extends StatelessWidget {
  final String? text; // Make text nullable
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor; // Add borderColor parameter
  final double borderWidth; // Add borderWidth parameter
  final double elevation; // Add elevation parameter
  final double? width;
  final IconData? iconData;
  final Color? iconColor; // Add iconColor parameter
  final bool debounce;

  RoundedButton({
    super.key,
    this.text, // Update text parameter to be nullable
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor =
        const Color.fromRGBO(230, 128, 120, 1), // Set default border color
    this.borderWidth = 2.0, // Set default border width
    this.elevation = 3.0, // Set default elevation
    this.width = 300.0,
    this.iconData,
    this.iconColor, // Initialize iconColor parameter
    this.debounce = false,
  });

  // Debouncer with a 500ms delay
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: ElevatedButton(
        onPressed: (onPressed != null && debounce)
            ? () => _debouncer.run(onPressed!)
            : onPressed, // Call the debouncer class when the button is tapped
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: borderColor, width: borderWidth), // Border
          ),
          fixedSize: Size(width!, 50.0),
          elevation: elevation, // Shadow
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconData != null)
              Icon(
                iconData,
                size: 24,
                color: iconColor, // Set icon color
              ),
            SizedBox(
              width: iconData != null ? 8 : 0,
            ),
            if (text != null) // Show the text element only if text is not null
              Text(
                text!,
                style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds),
        action); // Use the correct syntax for creating a new instance of Timer
  }
}
