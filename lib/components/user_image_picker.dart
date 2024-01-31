import 'dart:convert';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final List<String?> userImagesList;
  final Function onPickImage;
  final String? userImagePath;
  final Function userPickedImage;
  final String? base64Image; // Variable to store the base64 encoded image

  const UserImagePicker({
    super.key,
    required this.userImagesList,
    required this.onPickImage,
    required this.userImagePath,
    required this.userPickedImage,
    required this.base64Image,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  String? userImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  bool userPickedImageFromFiles = false;
  bool userPickedImageFromCamera = false;
  String? base64Image; // Variable to store the base64 encoded image

  @override
  void initState() {
    userImagePath = widget.userImagePath;
    base64Image = widget.base64Image;
    super.initState();
  }

  BuildContext getContext() {
    return context;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? decodedBase64Image;
    if (base64Image != null && base64Image!.isNotEmpty) {
      decodedBase64Image = base64Decode(base64Image!);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (decodedBase64Image == null)
              for (String? image in widget.userImagesList)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      userImagePath = image;
                      userPickedImageFromFiles = false;
                      userPickedImageFromCamera = false;
                      widget.onPickImage(userImagePath);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: userImagePath == image
                            ? const Color(0xFFEDA732)
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(image!),
                      backgroundColor:
                          userImagePath == image ? Colors.white38 : null,
                      child: userImagePath == image
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                    ),
                  ),
                ),
            if (!kIsWeb) // For picking image from gallery
              GestureDetector(
                onTap: () {
                  _pickImage().then((_) {
                    setState(() {
                      userPickedImageFromFiles = true;
                      userPickedImageFromCamera = false;
                      widget.userPickedImage(base64Image);
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: userPickedImageFromFiles
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: userPickedImageFromFiles
                        ? AssetImage(userImagePath!)
                        : null,
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      userPickedImageFromFiles ? Icons.check : Icons.add,
                      color: userPickedImageFromFiles
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            if (!kIsWeb) // For taking photo with camera
              GestureDetector(
                onTap: () {
                  _takePhoto().then((_) {
                    setState(() {
                      userPickedImageFromFiles = false;
                      userPickedImageFromCamera = true;
                      widget.userPickedImage(base64Image);
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: userPickedImageFromCamera
                          ? Colors.green
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                      backgroundImage: userPickedImageFromCamera
                          ? AssetImage(userImagePath!)
                          : null,
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        userPickedImageFromCamera
                            ? Icons.check
                            : Icons.camera_alt,
                        color: userPickedImageFromCamera
                            ? Colors.black
                            : Colors.white,
                      )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return; // Add this line to handle cancellation

      final compressedImage = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 400,
        minHeight: 400,
        quality: 25, // Adjust the quality
      );

      if (compressedImage != null) {
        setState(() {
          base64Image = base64Encode(compressedImage);

          userImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      CustomDialog.show(
        context: getContext(),
        title: 'Error',
        content: 'Error picking image: $e',
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return; // Add this line to handle cancellation

      final compressedImage = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 400,
        minHeight: 400,
        quality: 25, // Adjust the quality
      );

      if (compressedImage != null) {
        setState(() {
          base64Image = base64Encode(compressedImage);

          userImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      CustomDialog.show(
        context: getContext(),
        title: 'Error',
        content: 'Error picking image: $e',
      );
    }
  }
}
