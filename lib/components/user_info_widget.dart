import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/components/conver_image_data.dart';
import 'package:flutter/material.dart';

// The UserImage class serves as a model to store and manage user-related image data.
class UserImage {
  final String email; // The user's email address.
  String?
      userImagePath; // The path to the user's image stored locally or in the cloud.
  String?
      base64Image; // The base64 encoded string of the user's image for direct display in the UI or storage.
  bool
      userPickedImage; // A flag indicating whether the user has picked an image.

  UserImage({
    required this.email,
    this.userImagePath,
    this.base64Image,
    required this.userPickedImage,
  });
}

// UserInfoWidget is a StatefulWidget that displays the user's information, including the profile picture and basic details.
class UserInfoWidget extends StatefulWidget {
  final User?
      loggedInUser; // Firebase User object for the currently logged-in user.

  // Constructor requiring the logged-in Firebase User object.
  const UserInfoWidget({super.key, required this.loggedInUser});

  @override
  UserInfoWidgetState createState() => UserInfoWidgetState();
}

class UserInfoWidgetState extends State<UserInfoWidget> {
  late Future<UserImage> _userDataFuture; // Future to hold the UserImage data.
  bool userPickedImage =
      false; // Flag to track if a user image has been picked.
  String? base64Image; // Variable to store the base64 encoded image.

  @override
  void initState() {
    super.initState();
    // Initialize _userDataFuture with user data from Firestore based on the logged-in user's email.
    _userDataFuture = getUserData(widget.loggedInUser?.email);
  }

  // Method to refresh the user data when the user changes their image.
  void refreshUserData() {
    setState(() {
      _userDataFuture = getUserData(widget.loggedInUser?.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for the widget.
      width: double.infinity, // Widget takes the full available width.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FutureBuilder to asynchronously fetch and display the user's image and details.
          FutureBuilder<UserImage>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display a loading indicator while the user data is being fetched.
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Display an error message if there's an issue fetching the user data.
                return Text('Error: ${snapshot.error}');
              } else {
                // On successful fetch, display the user's image and provide an option to change it.
                var userImage = snapshot.data!;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    UserInfoDetails(
                        user: userImage, loggedInUser: widget.loggedInUser),
                    Positioned(
                      // Position the add/change image button.
                      right: MediaQuery.of(context).size.width * 0.3,
                      child: IconButton(
                        icon:
                            const Icon(Icons.add_circle, color: Colors.black54),
                        onPressed: () {
                          // Show a modal bottom sheet to allow the user to pick or change their image.
                        },
                      ),
                    )
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Async method to fetch user data from Firestore based on the user's email.

  Future<UserImage> getUserData(String? userEmail) async {
    var userData =
        FirebaseFirestore.instance.collection('users').doc(userEmail);

    var userImagePath = (await userData.get())['userImagePath'];
    var base64Image = (await userData.get())['base64Image'];
    var userPickedImage = (await userData.get())['userPickedImage'];

    return UserImage(
      email: userEmail!,
      userImagePath: userImagePath,
      base64Image: base64Image,
      userPickedImage: userPickedImage,
    );
  }
}

// UserInfoDetails is a StatelessWidget that displays detailed information about the user, including their display name and email.
class UserInfoDetails extends StatelessWidget {
  final UserImage user; // UserImage object containing the user's image data.
  final User?
      loggedInUser; // Firebase User object for the currently logged-in user.

  // Constructor requiring UserImage and Firebase User objects.
  const UserInfoDetails(
      {super.key, required this.user, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the user's profile picture.
        SizedBox(height: 100, child: ImageClip(user: user)),
        // Display a welcome message with the user's display name.
        Text(
          loggedInUser != null
              ? 'Welcome, ${getDisplayName(loggedInUser!)}!'
              : 'Not Logged In',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Display the user's email address.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, color: Colors.black54),
            Text(
              loggedInUser != null
                  ? 'Logged In as: ${loggedInUser!.email}'
                  : 'Not Logged In',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String getDisplayName(User user) {
    return user.displayName ?? user.email?.split('@')[0] ?? '';
  }
}
