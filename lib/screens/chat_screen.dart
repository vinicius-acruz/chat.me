import 'package:chat_me/components/conver_image_data.dart';
import 'package:chat_me/components/show_alert_dialog.dart';
import 'package:chat_me/components/user.dart';
import 'package:flutter/material.dart';
import 'package:chat_me/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  final UserData user;
  const ChatScreen({super.key, required this.user});

  static const String id = 'chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText = '';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: null,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: ImageClip(
                      userImagePath: widget.user.userImagePath,
                      userPickedImage: widget.user.userPickedImage,
                      base64Image: widget.user.base64Image,
                      size: 50),
                ),
                const SizedBox(width: 10), // Provide some horizontal spacing
                Text(widget.user.displayName), // Use the user's display name
              ],
            ),
          ],
        ),
        backgroundColor: kAppBarColor.withOpacity(0.8),
      ),
      body: Stack(
        children: [
          //All background container color (including off the safe area)
          Container(
            color: kMessageContainerColor,
          ),
          // Safe area background image
          SafeArea(
            top: false,
            child: Container(
                //color: const Color.fromRGBO(247, 243, 238, 1),
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/chat_wallpaper.png'),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MessageStream(user: widget.user),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    decoration: kMessageContainerDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: messageTextController,
                            onChanged: (value) {
                              messageText = value;
                            },
                            textCapitalization: TextCapitalization.sentences,
                            decoration:
                                kTextFieldDecoration, // Use the InputDecoration
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            messageTextController.clear();
                            final senderConversationDoc = _firestore
                                .collection('users')
                                .doc(loggedInUser.email)
                                .collection('conversations')
                                .doc(widget.user.email);

                            final receiverConversationDoc = _firestore
                                .collection('users')
                                .doc(widget.user.email)
                                .collection('conversations')
                                .doc(loggedInUser.email);

                            // Adding message to sender's collection
                            senderConversationDoc.collection('messages').add({
                              'text': messageText,
                              'sender': loggedInUser.email,
                              'receiver': widget.user.email,
                              'time': FieldValue.serverTimestamp(),
                            });

                            // Adding message to receiver's collection
                            if (loggedInUser.email != widget.user.email) {
                              receiverConversationDoc
                                  .collection('messages')
                                  .add({
                                'text': messageText,
                                'sender': loggedInUser.email,
                                'receiver': widget.user.email,
                                'time': FieldValue.serverTimestamp(),
                              });
                            }

                            // Update last message timestamp in conversations
                            senderConversationDoc.set({
                              'lastMessageTimestamp':
                                  FieldValue.serverTimestamp(),
                              'lastMessage': messageText,
                            }, SetOptions(merge: true));

                            if (loggedInUser.email != widget.user.email) {
                              receiverConversationDoc.set({
                                'lastMessageTimestamp':
                                    FieldValue.serverTimestamp(),
                                'lastMessage': messageText,
                              }, SetOptions(merge: true));
                            }

                            messageText = '';
                          },
                          child: const Text(
                            'Send',
                            style: kSendButtonTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final UserData user;
  const MessageStream({super.key, required this.user});

  String _getDateLabel(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.year == today.year &&
        dateTime.month == today.month &&
        dateTime.day == today.day) {
      return 'Today';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user.id.isEmpty || loggedInUser.uid.isEmpty) {
      // Return some loading widget or handle the case where user.id or loggedInUser.uid is not valid
      return const CircularProgressIndicator();
    }

    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(loggedInUser.email)
            .collection('conversations')
            .doc(user.email)
            .collection('messages')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            );
          }
          final messages = snapshot.data!.docs.reversed;

          DateTime? previousDate;
          List<Widget> messageWidgets = [];

          for (var message in messages) {
            final currentUser = loggedInUser.email;
            final messageData = message.data() as Map<String, dynamic>;
            final messageText = messageData['text'];
            final messageSender = messageData['sender'];
            final Timestamp? timestamp = messageData['time'];
            final DateTime messageDate = timestamp?.toDate() ?? DateTime.now();

            // Check if the message is the start of a new day
            if (previousDate == null ||
                previousDate.day != messageDate.day ||
                previousDate.month != messageDate.month ||
                previousDate.year != messageDate.year) {
              // Insert date label widget
              messageWidgets.add(
                Center(
                  child: Text(
                    _getDateLabel(messageDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            }

            previousDate = messageDate;

            if (messageText != null && messageSender != null) {
              final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser ==
                    messageSender, // Check if the current user is the sender
                serverTimestamp: timestamp,
                localTimestamp: DateTime.now(), // Current local timestamp
              );
              messageWidgets.add(messageBubble);
            }
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageWidgets,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final Timestamp? serverTimestamp;
  final DateTime localTimestamp;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.serverTimestamp,
    required this.localTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Use the server timestamp if available; otherwise, use the local timestamp
    DateTime displayTime = serverTimestamp?.toDate() ?? localTimestamp;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sender,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
            Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 30.0 : 0.0),
                topRight: Radius.circular(isMe ? 0.0 : 30.0),
                bottomLeft: const Radius.circular(30.0),
                bottomRight: const Radius.circular(30.0),
              ),
              elevation: 5.0,
              color:
                  isMe ? const Color.fromRGBO(253, 181, 181, 1) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.black54 : Colors.black54,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatTimestamp(displayTime), // Use the display time
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 10,
              ),
            ),
          ]),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Format the DateTime
  }
}
