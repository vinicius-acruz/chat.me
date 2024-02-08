// Importing necessary packages and files
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/user.dart';
import 'package:chat_me/components/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

// ContactsScreen is a StatefulWidget. This is the widget that user interacts with.
class ContactsScreen extends StatefulWidget {
  // Identifier for the screen
  static const String id = 'contacts_screen';

  // Constructor for ContactsScreen
  const ContactsScreen({super.key});

  // Creating the state for this widget
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

// The state for ContactsScreen
class _ContactsScreenState extends State<ContactsScreen> {
  // Instance of Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Instance of FirebaseAuth
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Method to get the context
  BuildContext getContext() {
    return context;
  }

  // Method called when this object is inserted into the tree.
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // Method to get the current user
  void getCurrentUser() {
    try {
      final user = auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      // Show custom dialog
      CustomDialog.show(
        context: context,
        title: 'Error',
        content: 'An error occurred while getting the current user. $e',
        bottomButtonText: 'OK',
        onOkPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  // Method to build the widget
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Stream of data from Firestore
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for data
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Map the documents to UserData objects
        final List<UserData> users = snapshot.data!.docs
            .map((doc) => UserData.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Build a list of tiles for each user
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final UserImage userImage = UserImage(
                email: users[index].email,
                userImagePath: users[index].userImagePath,
                base64Image: users[index].base64Image,
                userPickedImage: users[index].userPickedImage);

            return ListTile(
              visualDensity: const VisualDensity(vertical: 4),
              leading: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 2.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: ImageClip(user: userImage, size: 60)),
              title: Text(users[index].displayName),
              subtitle: Text(users[index].email),
              onTap: () async {
                // Create a new conversation in Firestore between the logged-in user and the selected user
                final DocumentReference senderCollection = firestore
                    .collection('users')
                    .doc(loggedInUser.email)
                    .collection('conversations')
                    .doc(users[index].email);

                final DocumentReference receiverCollection = firestore
                    .collection('users')
                    .doc(users[index].email)
                    .collection('conversations')
                    .doc(loggedInUser.email);

                senderCollection.set({
                  'sender': loggedInUser.email,
                  'receiver': users[index].email,
                  'time': FieldValue.serverTimestamp(),
                  'contactImagePath': users[index].userImagePath,
                  'contactBase64Image': users[index].base64Image,
                  'contactDisplayName': users[index].displayName,
                  'contactUserPickedImage': users[index].userPickedImage,
                });

                if (loggedInUser.email != users[index].email) {
                  // Fetch logged-in user's data from Firestore
                  DocumentSnapshot currentUserDoc = await firestore
                      .collection('users')
                      .doc(loggedInUser.email)
                      .get();
                  Map<String, dynamic> currentUserData =
                      currentUserDoc.data() as Map<String, dynamic>;

                  receiverCollection.set({
                    'sender': users[index].email,
                    'receiver': loggedInUser.email,
                    'time': FieldValue.serverTimestamp(),
                    'contactBase64Image': currentUserData['base64Image'],
                    'contactDisplayName': currentUserData['displayName'],
                    'contactUserPickedImage':
                        currentUserData['userPickedImage'],
                  });
                }

                // Navigate to the ChatScreen for the conversation
                Navigator.push(
                  getContext(),
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      user: users[index],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
