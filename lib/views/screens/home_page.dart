import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../helper/firebase_auth_helper.dart';
import '../../helper/firestore_helper.dart';
import '../../helper/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertUserFormKey = GlobalKey<FormState>();
  late File? image = null;
  final ImagePicker _imagePicker = ImagePicker();

  bool isAnonymous = false;
  bool isEmailPassword = false;

  @override
  void initState() {
    super.initState();
    checkAuthMethod();
  }

  void checkAuthMethod() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isAnonymous = user.isAnonymous;
      isEmailPassword = user.providerData.any((userInfo) =>
          userInfo.providerId == 'password' || userInfo.providerId == 'email');
    }
  }

  Future<void> image_pick(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  void chooseImage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                image_pick(ImageSource.camera);
                Get.back();
              },
              icon: const Icon(Icons.camera, size: 70),
            ),
            IconButton(
              onPressed: () {
                image_pick(ImageSource.gallery);
                Get.back();
              },
              icon: const Icon(Icons.photo, size: 70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${FireBaseAuthHelper.firebaseAuth.currentUser!.email?.split("@")[0]}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/SettingsPage");
          },
          icon: const Icon(Icons.person_pin, size: 30),
        ),
        actions: [
          IconButton(
              onPressed: () {
                FireBaseAuthHelper.fireBaseAuthHelper.signOut();
                Get.toNamed("/Sign_in");
              },
              icon: const Icon(CupertinoIcons.power))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreHelper.firestoreHelper.fetchallusers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("ERROR : ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                (data == null) ? [] : data.docs;
            return ListView.builder(
              itemCount: allDocs.length,
              itemBuilder: (context, index) {
                if ((allDocs[index]['uid'] ==
                    FireBaseAuthHelper.firebaseAuth.currentUser!.uid)) {
                  return Container();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12,left: 12,top: 8),
                    child: Container(
                      height: Get.height * 0.11,
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () async {
                              Globals.u1 = FireBaseAuthHelper
                                  .firebaseAuth.currentUser!.uid;
                              Globals.u2 = allDocs[index]['uid'];
                              Globals.username = allDocs[index]['email'];
                              Get.toNamed("/chat_page", arguments: <String>[
                                FireBaseAuthHelper
                                    .firebaseAuth.currentUser!.uid,
                                allDocs[index]['uid'],
                              ]);
                            },
                            leading: GestureDetector(
                              onTap: () {
                                chooseImage();
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade400,
                                radius: 30,
                                backgroundImage: image != null
                                    ? FileImage(image!)
                                    : AssetImage("assets/images/girl.png")
                                        as ImageProvider,

                                // image != null
                                //     ? FileImage(image!)
                                //     : (FirebaseAuth.instance.currentUser!.photoURL != null
                                //     ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!) as ImageProvider
                                //     : const AssetImage('assets/images/google.png')),
                              ),
                            ),
                            title: Text(
                                '${allDocs[index]['email']}'.split("@")[0]),
                            trailing: Container(
                              height: 15,
                              width: 15,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
