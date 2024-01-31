import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/user.dart';
import 'package:chat_me/components/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  static const String id = 'inbox_screen';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedInUser = _auth.currentUser;

    if (loggedInUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // ignore: no_leading_underscores_for_local_identifiers
    String _formatTimestamp(Timestamp? timestamp) {
      if (timestamp == null) return 'Time not available';
      DateTime dateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      return dateTime.day == now.day &&
              dateTime.month == now.month &&
              dateTime.year == now.year
          ? DateFormat('hh:mm a').format(dateTime)
          : DateFormat('MM/dd/yyyy').format(dateTime);
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(loggedInUser.email)
                .collection('conversations')
                .orderBy('lastMessageTimestamp',
                    descending: true) // Sort by last message timestamp
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final conversations = snapshot.data!.docs
                  .map((doc) => ContactData.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id))
                  .toList();

              if (conversations.isEmpty) {
                return const Center(child: Text("No conversations yet."));
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final userImage = UserImage(
                    email: conversation.email,
                    userImagePath: conversation.contactUserImagePath ??
                        'images/default_user.png',
                    base64Image: conversation.contactBase64Image,
                    userPickedImage: conversation.contactUserPickedImage,
                  );

                  return ListTile(
                    visualDensity: const VisualDensity(vertical: 4),
                    leading: ImageClip(user: userImage, size: 60),
                    title: Text(conversation.contactDisplayName),
                    subtitle: Text(conversation.lastMessage ??
                        'No new messages'), // You need to store lastMessage as well
                    trailing: Text(
                        _formatTimestamp(conversation.lastMessageTimestamp)),
                    onTap: () {
                      final user = UserData(
                        id: conversation.id,
                        email: conversation.email,
                        displayName: conversation.contactDisplayName,
                        userImagePath: conversation.contactUserImagePath,
                        base64Image: conversation.contactBase64Image,
                        userPickedImage: conversation.contactUserPickedImage,
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(user: user)));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
