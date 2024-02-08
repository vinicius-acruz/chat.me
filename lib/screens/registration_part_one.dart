import 'package:flutter/material.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/components/user_image_picker.dart';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:chat_me/components/conver_image_data.dart'; // Assuming this handles conversion of images to data formats
import 'package:chat_me/components/user_images.dart'; // Assuming this holds user images data

// RegistrationPartOne is the first part of the user registration process.
class RegistrationPartOne extends StatefulWidget {
  // Callbacks to update user image, display name, and navigate to the next registration part.
  final Function(String? imagePath, String? base64, bool pickedImage)
      updateUserImage;
  final Function(String displayName) updateDisplayName;
  final VoidCallback goToNextPage;

  const RegistrationPartOne({
    Key? key,
    required this.updateUserImage,
    required this.updateDisplayName,
    required this.goToNextPage,
  }) : super(key: key);

  @override
  State<RegistrationPartOne> createState() => _RegistrationPartOneState();
}

class _RegistrationPartOneState extends State<RegistrationPartOne> {
  String? userImagePath;
  String? base64Image; // Variable to store the base64 encoded image string.
  bool userPickedImage =
      false; // Flag to indicate if a user has picked an image.
  String displayName = ''; // User input for display name.

  // This method handles the selection of a new image by updating the state
  // and invoking the callback with the new image details.
  void handleImagePicked(
      {String? imagePath, String? base64, required bool pickedImage}) {
    setState(() {
      userImagePath = imagePath;
      base64Image = base64;
      userPickedImage = pickedImage;
    });
    widget.updateUserImage(imagePath, base64, pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Center(
          child: Text(
            'Pick a user image',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            // a widget you have defined that displays the user's chosen image.

            ImageClip(
              userImagePath: userImagePath,
              base64Image: base64Image,
              userPickedImage: userPickedImage,
              size: 130,
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.black54),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SizedBox(
                            height: 250,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  UserImagePicker(
                                    userImagesList: ImageLists.userImagesList,
                                    userImagePath: userImagePath,
                                    base64Image: base64Image,
                                    onPickImage: (newImage) {
                                      handleImagePicked(
                                        imagePath: newImage,
                                        base64: base64Image,
                                        pickedImage: false,
                                      );
                                    },
                                    userPickedImage: (newBase64Image) {
                                      handleImagePicked(
                                        imagePath: userImagePath,
                                        base64: newBase64Image,
                                        pickedImage: true,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  RoundedButton(
                                    text: 'Ok',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
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
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        // TextField for entering the display name.
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: TextField(
            textAlign: TextAlign.center,
            onChanged: (value) {
              displayName = value; // Update display name as the user types.
            },
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter your display name',
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        // Button to proceed to the next part of the registration.
        RoundedButton(
          text: 'Next',
          onPressed: () {
            // Check if the user has selected an image and entered a display name.
            if (userImagePath == null && base64Image == null) {
              // If no image is selected, show a dialog warning the user.
              CustomDialog.show(
                context: context,
                title: 'Image Selection',
                content: 'Please select a user image before registering.',
                bottomButtonColor: Colors.grey,
                bottomButtonText: 'OK',
                bottomButtonTextColor: Colors.black54,
              );
              return;
            }
            if (displayName.isEmpty) {
              // If no display name is entered, show a dialog warning the user.
              CustomDialog.show(
                context: context,
                title: 'Name',
                content: 'Please enter a user name before registering.',
                bottomButtonColor: Colors.grey,
                bottomButtonText: 'OK',
                bottomButtonTextColor: Colors.white,
              );
              return;
            }
            // If both an image has been selected and a display name entered,
            // proceed to the next part of the registration.
            if (displayName.isNotEmpty &&
                (userImagePath != null || base64Image != null)) {
              widget.updateDisplayName(displayName);
              widget.goToNextPage();
            } else {
              // Handle any other case where the user cannot proceed (not expected to occur).
            }
          },
        ),
      ],
    );
  }
}
