import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../controller/provider/themeprovider.dart';
import '../../helper/firebase_auth_helper.dart';
import '../../helper/firestore_helper.dart';
import '../../helper/globals.dart';

class chatpage extends StatefulWidget {
  const chatpage({Key? key});

  @override
  _chatpageState createState() => _chatpageState();
}

class _chatpageState extends State<chatpage> {
  final TextEditingController sendMessageController = TextEditingController();
  late Future<QuerySnapshot<Map<String, dynamic>>> getAllMessages;

  @override
  void initState() {
    super.initState();
    getAllMessages = FirestoreHelper.firestoreHelper
        .displayMessage(uid1: Globals.u1, uid2: Globals.u2);
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await FirestoreHelper.firestoreHelper.deleteMessage(
      chatRoomId: chatRoomId,
      messageId: messageId,
    );
    setState(() {
      getAllMessages = FirestoreHelper.firestoreHelper
          .displayMessage(uid1: Globals.u1, uid2: Globals.u2);
    });
  }

  Future<void> editMessage(
      String chatRoomId, String messageId, String newMessageText) async {
    await FirestoreHelper.firestoreHelper.editMessage(
      chatRoomId: chatRoomId,
      messageId: messageId,
      newMessageText: newMessageText,
    );
    setState(() {
      getAllMessages = FirestoreHelper.firestoreHelper
          .displayMessage(uid1: Globals.u1, uid2: Globals.u2);
    });
  }

  Future<String?> showEditMessageDialog(String initialMessage) async {
    TextEditingController editController =
        TextEditingController(text: initialMessage);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Edit your message...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel edit
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String editedMessage = editController.text;
                Navigator.of(context)
                    .pop(editedMessage); // Return edited message
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> args =
        ModalRoute.of(context)!.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text(Globals.username.split("@")[0]),
        backgroundColor: Provider.of<ThemeProvider>(context, listen: true)
            .changethemeModel
            .isDark?Colors.black54:Colors.grey.shade100,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam)),
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined))
        ],
      ),
      body: Container(
        decoration:Provider.of<ThemeProvider>(context, listen: true)
            .changethemeModel
            .isDark?BoxDecoration(
          image: DecorationImage(
            opacity: 0.7,
            image: AssetImage("assets/images/chatbgb.jpg"),
            fit: BoxFit.fill,
          ),
        ):BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chatbg.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: FutureBuilder(
                  future: getAllMessages,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("ERROR : ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          allDocs = (data == null) ? [] : data.docs;

                      return (allDocs.isEmpty)
                          ? const Center(
                              child: Text("No any msg yet..."),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: allDocs.length,
                              itemBuilder: (context, index) {
                                final messageData = allDocs[index].data();
                                final messageId = allDocs[index].id;

                                return Slidable(
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          deleteMessage(
                                              "${Globals.u1}_${Globals.u2}",
                                              messageId);
                                        },
                                        backgroundColor:
                                            const Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        flex: 2,
                                        onPressed: (context) async {
                                          final editedMessage =
                                              await showEditMessageDialog(
                                                  messageData['msg']);
                                          if (editedMessage != null) {
                                            editMessage(
                                                "${Globals.u1}_${Globals.u2}",
                                                messageId,
                                                editedMessage);
                                          }
                                        },
                                        backgroundColor:
                                            const Color(0xFF7BC043),
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        allDocs[index].data()['sentBy'] ==
                                                FireBaseAuthHelper.firebaseAuth
                                                    .currentUser!.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            allDocs[index].data()['sentBy'] ==
                                                    FireBaseAuthHelper
                                                        .firebaseAuth
                                                        .currentUser!
                                                        .uid
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          allDocs[index].data()['sentBy'] ==
                                                  FireBaseAuthHelper
                                                      .firebaseAuth
                                                      .currentUser!
                                                      .uid
                                              ? BubbleSpecialThree(
                                                  text:
                                                      "${allDocs[index].data()['msg']}",
                                                  color: Color(0xFF1B97F3),
                                                  tail: false,
                                                  textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                  seen: true,
                                                )
                                              : BubbleSpecialThree(
                                                  text:
                                                      "${allDocs[index].data()['msg']}",
                                                  color: Colors.grey,
                                                  tail: false,
                                                  textStyle: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                  seen: false,
                                                  delivered: false,
                                                )
                                          // Card(
                                          //   margin: const EdgeInsets.all(8),
                                          //   // child: Chip(
                                          //   //   label: Column(
                                          //   //     crossAxisAlignment: allDocs[index]
                                          //   //         .data()['sentBy'] ==
                                          //   //         FireBaseAuthHelper
                                          //   //             .firebaseAuth
                                          //   //             .currentUser!
                                          //   //             .uid
                                          //   //         ? CrossAxisAlignment.end
                                          //   //         : CrossAxisAlignment.start,
                                          //   //     children: [
                                          //   //       Text(
                                          //   //           "${allDocs[index].data()['msg']}"),
                                          //   //       Row(
                                          //   //         children: [
                                          //   //           Text(
                                          //   //               "${allDocs[index].data()['timestamp'].toDate()}"
                                          //   //                   .split(".")[0]),
                                          //   //           (allDocs[index]
                                          //   //               .data()['sentBy'] ==
                                          //   //               FireBaseAuthHelper
                                          //   //                   .firebaseAuth
                                          //   //                   .currentUser!
                                          //   //                   .uid)
                                          //   //               ? const Icon(
                                          //   //             Icons.done_all_rounded,
                                          //   //             color: Colors.blue,
                                          //   //           )
                                          //   //               : IconButton(
                                          //   //             onPressed: () {},
                                          //   //             icon: const Icon(
                                          //   //               Icons.r_mobiledata,
                                          //   //               size: 1,
                                          //   //             ),
                                          //   //           ),
                                          //   //         ],
                                          //   //       ),
                                          //   //     ],
                                          //   //   ),
                                          //   // ),
                                          // )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Provider.of<ThemeProvider>(context, listen: true)
                          .changethemeModel
                          .isDark?TextField(
                        controller: sendMessageController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.emoji_emotions,
                            size: 28,
                          ),
                          suffixIcon: Icon(
                            Icons.camera_alt,
                            size: 28,
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: "Message",
                        ),
                      ):TextField(
                        controller: sendMessageController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.emoji_emotions,
                            size: 28,
                          ),
                          suffixIcon: Icon(
                            Icons.camera_alt,
                            size: 28,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          hintText: "Message",
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send,size: 30,color: Color(0xFF1B97F3),),
                      onPressed: () async {
                        await FirestoreHelper.firestoreHelper.sendMessage(
                          uid1: args[0],
                          uid2: args[1],
                          msg: sendMessageController.text,
                        );
                        setState(() {
                          getAllMessages = FirestoreHelper.firestoreHelper
                              .displayMessage(
                              uid1: Globals.u1, uid2: Globals.u2);
                        });
                        sendMessageController.clear();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
