import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream_chat/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final chatDocs = chatSnapshot.data?.docs;
          return ListView.builder(
              reverse: true,
              itemCount: chatDocs!.length,
              itemBuilder: (context, index) => MessageBubble(
                userImage: chatDocs[index]['userImage'],
                  userName: chatDocs[index]['userName'],
                    message: chatDocs[index]['text'],
                    isMe: chatDocs[index]['userId'] == FirebaseAuth.instance.currentUser?.uid,
                    key: ValueKey(chatDocs[index].id)
                  ));
        });
  }
}
