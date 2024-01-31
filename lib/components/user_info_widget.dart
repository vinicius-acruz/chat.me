import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/components/user_image_picker.dart';
import 'package:chat_me/components/user_images.dart';
import 'package:flutter/material.dart';

class UserImage {
  final String email;
  String? userImagePath;
  String? base64Image;
  bool userPickedImage;

  UserImage({
    required this.email,
    required this.userImagePath,
    required this.base64Image,
    required this.userPickedImage,
  });
}

class UserInfoWidget extends StatefulWidget {
  final User? loggedInUser;

  const UserInfoWidget({super.key, required this.loggedInUser});

  @override
  UserInfoWidgetState createState() => UserInfoWidgetState();
}

class UserInfoWidgetState extends State<UserInfoWidget> {
  late Future<UserImage> _userDataFuture;
  late int imageCounter = 0;
  bool hiddenList = false;
  bool userPickedImage = false;
  String? base64Image; // Variable to store the base64 encoded image

  @override
  void initState() {
    super.initState();
    _userDataFuture = getUserData(widget.loggedInUser?.email);
  }

  void refreshUserData() {
    setState(() {
      _userDataFuture = getUserData(widget.loggedInUser?.email);
    });
  } //Method to refresh image after user changes it

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Set a fixed height for the widget
      width: double.infinity, // Set the width to take the full available width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<UserImage>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 50, // Fixed height for the progress indicator
                  width: 50, // Fixed width for the progress indicator
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                var userImage = snapshot.data!;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    UserInfoDetails(
                        user: userImage, loggedInUser: widget.loggedInUser),
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.3,
                      child: IconButton(
                        icon:
                            const Icon(Icons.add_circle, color: Colors.black54),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                //Use StatefulBuilder here to update the modal's UI without needing to close it and open it again

                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return SizedBox(
                                    height: 250,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          UserImagePicker(
                                            userImagesList:
                                                ImageLists.userImagesList,
                                            userImagePath:
                                                userImage.userImagePath,
                                            base64Image: userImage.base64Image,
                                            onPickImage: (newImage) {
                                              setState(() {
                                                // This will now update the modal's UI
                                                userImage.userImagePath =
                                                    newImage;
                                                userPickedImage = false;
                                              });
                                            },
                                            userPickedImage: (base64Image) {
                                              setState(() {
                                                userImage.base64Image =
                                                    base64Image;
                                                userPickedImage = true;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          RoundedButton(
                                            width: 150,
                                            text: 'Save',
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userImage.email)
                                                  .update({
                                                'userImagePath':
                                                    userImage.userImagePath,
                                                'base64Image':
                                                    userImage.base64Image,
                                                'userPickedImage':
                                                    userPickedImage,
                                              });
                                              refreshUserData();
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
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

class UserInfoDetails extends StatelessWidget {
  final UserImage user;
  final User? loggedInUser;

  const UserInfoDetails(
      {super.key, required this.user, required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100, child: ImageClip(user: user)),
        Text(
          loggedInUser != null
              ? 'Welcome, ${getDisplayName(loggedInUser!)}!'
              : 'Not Logged In',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, color: Colors.black54),
            const SizedBox(width: 5),
            Text(
              loggedInUser != null
                  ? 'Logged In as: ${loggedInUser!.email}'
                  : 'Not Logged In',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  String getDisplayName(User user) {
    return user.displayName ?? user.email?.split('@')[0] ?? '';
  }
}
