import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_new_way/contants/contant.dart';

final _fireStore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'Chat_Screen';

  String? channelName;

  ChatScreen({Key? key, this.channelName}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextControllor = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? textMessage;
  String? timeHourAndMin;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  String getCurrentTime() {
    setState(() {
      timeHourAndMin = '${DateTime.now().hour}:${DateTime.now().minute}';
    });
    return timeHourAndMin!;
  }

  dynamic getHourAndTime() {
    String? timeNow;
    setState(() {
      timeNow = '${DateTime.now()}';
    });
    return timeNow!;
  }

  // void getMessageStream() async {
  //   await for (var snapShot in _fireStore.collection('meassage').snapshots()) {
  //     for (var meassage in snapShot.docs) {
  //       print(meassage.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              channelName: widget.channelName,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageTextControllor,
                    onChanged: (value) {
                      //Do something with the user input.
                      textMessage = value;
                    },
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    messageTextControllor.clear();
                    _fireStore.collection('meassage').add({
                      'channelName': widget.channelName,
                      'text': textMessage,
                      'sender': loggedInUser!.email,
                      'time': DateTime.now(),
                      'timeHourAndTime': getCurrentTime(),
                    });
                  },
                  child: const Text(
                    'Send',
                    style: kSendButtonTextStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  MessageStream({Key? key, this.channelName}) : super(key: key);

  final String? channelName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('meassage')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            if (message['channelName'] == channelName) {
              final messageText = message['text'];
              final messageEmail = message['sender'];
              // final messageTime = message['timestamp'] == null
              //     ? Timestamp.fromMicrosecondsSinceEpoch()
              //     : message['timestamp'] as Timestamp;
              // final messageTime = message['time'] as Timestamp;
              final messageTime = message["time"];
              final timeHourMin = message['timeHourAndTime'];
              final currentUser = loggedInUser!.email;

              final messageBubble = MessageBubble(
                sender: messageEmail,
                text: messageText,
                isMe: currentUser == messageEmail,
                time: messageTime,
                timeHourAndMin: timeHourMin,
              );
              messageBubbles.add(messageBubble);
              messageBubbles.sort((a, b) => b.time!.compareTo(a.time!));
            }
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender, this.text, this.time, this.isMe, this.timeHourAndMin});

  final String? text;
  final String? sender;
  final bool? isMe;
  final Timestamp? time;
  final String? timeHourAndMin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Text(
          //   ' $sender ${time!.toDate()}', // add this only if you want to show the time along with the email. If you dont want this then don't add this DateTime thing
          //   style: TextStyle(color: Colors.black54, fontSize: 12),
          // ),
          Material(
            elevation: 5.0,
            borderRadius: isMe!
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0)),
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text!,
                style: TextStyle(
                    fontSize: 15.0,
                    color: isMe! ? Colors.white : Colors.black54),
              ),
            ),
          ),
          Text(
            '$timeHourAndMin',
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
