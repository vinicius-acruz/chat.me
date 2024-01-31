import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String email;

  final String? userImagePath;
  final String? base64Image;
  final String displayName;
  final bool userPickedImage;

  UserData({
    required this.id,
    required this.email,
    this.userImagePath,
    this.base64Image,
    required this.displayName,
    required this.userPickedImage,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      id: data['id'] ??
          'Could not fetch data', // Provide a default value if null
      email: data['email'] ??
          'Could not fetch data', // Provide a default value if null

      userImagePath: data['userImagePath'],
      base64Image: data['base64Image'] ?? '',
      userPickedImage: data['userPickedImage'] ?? false,
      displayName: data['displayName'] ?? 'Could not fetch name',
    );
  }
}

class ContactData {
  final String id;
  final String email;

  final String? contactUserImagePath;
  final String? contactBase64Image;
  final String contactDisplayName;
  final bool contactUserPickedImage;
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;

  ContactData({
    required this.id,
    required this.email,
    this.contactUserImagePath,
    this.contactBase64Image,
    required this.contactDisplayName,
    required this.contactUserPickedImage,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  factory ContactData.fromMap(Map<String, dynamic> data, String documentId) {
    return ContactData(
      id: documentId, // Use the document ID as the ID
      email: data['receiver'] ??
          'No email provided', // Map the 'receiver' field from Firestore
      contactUserImagePath: data[
          'contactImagePath'], // Map the 'contactImagePath' field from Firestore
      contactBase64Image: data[
          'contactBase64Image'], // Map the 'contactBase64Image' field from Firestore
      contactUserPickedImage: data['contactUserPickedImage'] ??
          false, // Map the 'contactuserPickedImage' field from Firestore
      contactDisplayName: data['contactDisplayName'] ??
          'No name provided', // Map the 'contactDisplayName' field from Firestore
      lastMessage: data['lastMessage'] as String?,
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp?,
    );
  }
}
