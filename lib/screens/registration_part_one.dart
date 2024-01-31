import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:chat_me/components/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/components/user_image_picker.dart';
import 'package:chat_me/components/rounded_button.dart';
import 'package:chat_me/components/user_images.dart';

class RegistrationPartOne extends StatefulWidget {
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
  String? base64Image; // Variable to store the base64 encoded image
  bool userPickedImage = false;
  String displayName = '';
  ValueNotifier<UserImage?> userImageNotifier = ValueNotifier(null);

  // This method is used to handle image picking
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
            // ImageClip component, assuming you have this defined somewhere
            // If it's a custom widget, replace with the appropriate widget
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
                                    width: 150,
                                    text: 'Ok',
                                    onPressed: () {
                                      setState(() {});
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
        // TextField for Display Name
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: TextField(
            textAlign: TextAlign.center,
            onChanged: (value) {
              displayName = value;
            },
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter your display name',
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        RoundedButton(
          text: 'Next',
          onPressed: () {
            // Validate if necessary and then navigate to the next page
            if (userImagePath == null && base64Image == null) {
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

            if (displayName.isNotEmpty &&
                (userImagePath != null || base64Image != null)) {
              widget.goToNextPage(); // Navigate to RegistrationPartTwo
              widget.updateDisplayName(
                  displayName); // Pass the displayName to the parent widget
            } else {
              // Show some error if the name is not entered or image is not picked
            }
          },
        ),
      ],
    );
  }
}
