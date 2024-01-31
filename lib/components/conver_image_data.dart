import 'dart:convert';
import 'package:chat_me/components/user_info_widget.dart';
import 'package:flutter/material.dart';

class ImageClip extends StatelessWidget {
  const ImageClip({
    Key? key,
    this.user,
    this.size = 100,
    this.userPickedImage,
    this.userImagePath,
    this.base64Image,
  }) : super(key: key);

  final UserImage? user;
  final double size;
  final bool? userPickedImage;
  final String? userImagePath;
  final String? base64Image;

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    // Determine if the user object is provided or separate image parameters are used
    bool isUserPickedImage =
        user != null ? user!.userPickedImage : userPickedImage ?? false;
    String? selectedBase64Image =
        user != null ? user!.base64Image : base64Image;
    String? selectedUserImagePath =
        user != null ? user!.userImagePath : userImagePath;

    // Check if the user picked an image and the base64Image is not null or empty
    if (isUserPickedImage &&
        selectedBase64Image != null &&
        selectedBase64Image.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(selectedBase64Image));
      } catch (e) {
        // Fallback to a default image if the base64 image is not valid
        imageProvider =
            const AssetImage('images/default_user.png'); // Adjust the asset
      }
    } else {
      // Use the userImagePath if available, otherwise, use a default image
      imageProvider =
          selectedUserImagePath != null && selectedUserImagePath.isNotEmpty
              ? AssetImage(selectedUserImagePath)
              : const AssetImage('images/default_user.png'); // Adjust the asset
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: imageProvider,
        ),
      ),
    );
  }
}
