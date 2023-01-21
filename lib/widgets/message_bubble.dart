import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String userName;
  final String userImage;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(userImage);
    return ListTile(
      leading: !isMe
          ? CircleAvatar(
              backgroundImage: NetworkImage(userImage),
            )
          : null,
      trailing: isMe
          ? CircleAvatar(
              backgroundImage: NetworkImage(userImage),
            )
          : null,
      title: Row(
        mainAxisAlignment:
            !isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: isMe ? Theme.of(context).accentColor : Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(12),
                    topLeft: const Radius.circular(12),
                    bottomLeft: !isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                    bottomRight: isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  )),
              // width: 150,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment:isMe? CrossAxisAlignment.end:CrossAxisAlignment.start ,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    maxLines: 10,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    message,
                    style: TextStyle(
                        color: isMe
                            ? Theme.of(context).accentTextTheme.headline1?.color
                            : Colors.deepPurple),
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
