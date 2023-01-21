import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final controller = TextEditingController();
  _sendMessage()async{
    controller.clear();
    FocusScope.of(context).unfocus();
    final user =  FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData['userName'],
      'userImage': userData['image_url'],
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      // margin:const EdgeInsets.only(top: 8),
      padding:const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
              // textAlign: TextAlign.justify,
              controller: controller,
              decoration:const InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: _enteredMessage.trim().isEmpty ? null :_sendMessage,
              icon:const Icon(Icons.send))
        ],
      ),
    );
  }
}
