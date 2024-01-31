import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/user.dart';
import 'package:chat_me/components/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  static const String id = 'contacts_screen';

  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _firestore = FirebaseFirestore.instance;

  final _auth = FirebaseAuth.instance;

  BuildContext getContext() {
    return context;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      //show custom dialog
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final users = snapshot.data!.docs
            .map((doc) => UserData.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userImage = UserImage(
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
                final senderCollection = _firestore
                    .collection('users')
                    .doc(loggedInUser.email)
                    .collection('conversations')
                    .doc(users[index].email);

                final receiverCollection = _firestore
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
                  DocumentSnapshot currentUserDoc = await _firestore
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
