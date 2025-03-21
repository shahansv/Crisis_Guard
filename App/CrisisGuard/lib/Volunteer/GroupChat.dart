import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GroupChat());
}

class GroupChat extends StatelessWidget {
  const GroupChat({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyChatPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyChatPage extends StatefulWidget {
  const MyChatPage({super.key, required this.title});

  final String title;

  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class ChatMessage {
  String messageContent;
  String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class _MyChatPageState extends State<MyChatPage> {
  int _counter = 0;
  String name = "";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _MyChatPageState() {
    // if (context.mounted) {
      Timer.periodic(Duration(seconds: 2), (_) {
        view_message();
      });
    }
  // }

  List<ChatMessage> messages = [];

  TextEditingController te_message = TextEditingController();

  List<String> camp_id_ = <String>[];
  List<String> message_ = <String>[];
  List<String> date_ = <String>[];

  // List<String> time_ = <String>[];

  Future<void> view_message() async {
    name = widget.title;

    setState(() {
      name = name;
    });

    List<String> camp_id = <String>[];
    List<String> to_id = <String>[];
    List<String> message = <String>[];
    List<String> date = <String>[];
    // List<String> time = <String>[];

    try {
      final pref = await SharedPreferences.getInstance();
      String urls = pref.getString('url').toString();
      String url = urls+'user_viewchat';

      var data = await http.post(Uri.parse(url), body: {
        'camp_id': pref.getString("lid").toString(),
      });
      var jsondata = json.decode(data.body);
      String status = jsondata['status'];
      print(status);

      var arr = jsondata["data"];
      print(arr);

      messages.clear();

      for (int i = 0; i < arr.length; i++) {
        camp_id.add(arr[i]['from'].toString());
        // to_id.add(arr[i]['to'].toString());
        message.add(arr[i]['msg']);
        date.add(arr[i]['date'].toString());
        // time.add(arr[i]['date'].toString());

        if (pref.getString("lid").toString() == arr[i]['from'].toString()) {
          messages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "sender"));
        } else {
          messages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "receiver"));
        }
      }

      // messages.add(ChatMessage(messageContent: "....", messageType: "sender"));

      setState(() {
        camp_id_ = camp_id;
        message_ = message;
        date_ = date;
        // time_ = time;

        messages = messages;
      });

      print(status);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
        leadingWidth: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 20.0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                splashRadius: 1.0,
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24.0,
                ),
              ),
            ),
            Text(
              name,
            ),
            SizedBox(
              width: 40.0,
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 50),
            physics: ScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding:
                    EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "receiver"
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType == "receiver"
                          ? Colors.grey.shade200
                          : Colors.blue[200]),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      messages[index].messageContent,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: te_message,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      String cid = "";
                      String message = te_message.text.toString();
                      if (message.isEmpty) {
                        return;
                      }
                      /////
                      try {
                        final pref = await SharedPreferences.getInstance();
                        String ip = pref.getString("url").toString();

                        String url = ip + "user_sendchat";

                        var data = await http.post(Uri.parse(url), body: {
                          'message': message,
                          'lid': pref.getString("lid").toString(),
                        });
                        var jsondata = json.decode(data.body);
                        String status = jsondata['status'];

                        te_message.text = "";

                        var arr = jsondata["data"];

                        setState(() {});

                        print("");
                      } catch (e) {
                        print("Error ------------------- " + e.toString());
                        //there is error during converting file image to base64 encoding.
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.cyan,
                    elevation: 0,
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
