import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._();

  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addusers({required Map<String, dynamic> data}) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await firebaseFirestore.collection('records').doc('users').get();

    Map<String, dynamic>? fetchData = documentSnapshot.data();

    int id = (fetchData == null) ? 0 : fetchData['id'];
    int length = (fetchData == null) ? 0 : fetchData['length'];

    //todo:check users already exit or not

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    bool isusersAlreadyExit = false;

    for (QueryDocumentSnapshot<Map<String, dynamic>> elements in allDocs) {
      if (data["uid"] == elements.data()["uid"]) {
        isusersAlreadyExit = true;
        break;
      } else {
        isusersAlreadyExit = false;
      }
    }
    if (isusersAlreadyExit == false) {
      await firebaseFirestore.collection("users").doc("${++id}").set(data);

      await firebaseFirestore
          .collection("records")
          .doc("users")
          .update({"id": id, "length": ++length});
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchallusers() {
    return firebaseFirestore.collection("users").snapshots();
  }

  Future<void> deleteusers({required String id}) async {
    await firebaseFirestore.collection("users").doc(id).delete();

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await firebaseFirestore.collection('records').doc('users').get();

    Map<String, dynamic>? fetchData = documentSnapshot.data();

    int length = (fetchData == null) ? 0 : fetchData['length'];

    await firebaseFirestore
        .collection("records")
        .doc("users")
        .update({"length": --length});
  }

  Future<void> sendMessage(
      {required String uid1, required String uid2, required String msg}) async {
    //todo:check if user are chatroom already exit or not
    String user1 = uid1;
    String user2 = uid2;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection("chat").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    bool isChatRoomIsAvailable = false;
    String fetchedUser1 = "";
    String fetchedUser2 = "";

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in allDocs) {
      String u1 = element.id.split("_")[0];
      String u2 = element.id.split("_")[1];

      if ((user1 == u1 || user1 == u2) && (user2 == u1 || user2 == u2)) {
        isChatRoomIsAvailable = true;
        fetchedUser1 = element.data()['users'][0];
        fetchedUser2 = element.data()['users'][1];
      }
    }

    if (isChatRoomIsAvailable == false) {
      await firebaseFirestore.collection("chat").doc("${uid1}_${uid2}").set({
        "users": [uid1, uid2]
      });

      await firebaseFirestore
          .collection("chat")
          .doc("${fetchedUser1}_${fetchedUser2}")
          .collection("messages")
          .add({
        "msg": msg,
        "timestamp": FieldValue.serverTimestamp(),
        "sentBy": uid1,
        "receivefirebaseFirestorey": uid2,
      });
    } else {
      await firebaseFirestore
          .collection("chat")
          .doc("${fetchedUser1}_${fetchedUser2}")
          .collection("messages")
          .add({
        "msg": msg,
        "timestamp": FieldValue.serverTimestamp(),
        "sentBy": uid1,
        "receivefirebaseFirestorey": uid2,
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> displayMessage(
      {required String uid1, required String uid2}) async {
    String user1 = uid1;
    String user2 = uid2;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection("chat").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    bool isChatRoomIsAvailable = false;
    String fetchedUser1 = "";
    String fetchedUser2 = "";

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in allDocs) {
      String u1 = element.id.split("_")[0];
      String u2 = element.id.split("_")[1];

      if ((user1 == u1 || user1 == u2) && (user2 == u1 || user2 == u2)) {
        isChatRoomIsAvailable = true;
        fetchedUser1 = element.id.split("_")[0];
        fetchedUser2 = element.id.split("_")[1];
      }
    }

    if (isChatRoomIsAvailable == false) {
      await firebaseFirestore.collection("chat").doc("${uid1}_${uid2}").set({
        "users": [uid1, uid2]
      });

      return await firebaseFirestore
          .collection("chat")
          .doc("${fetchedUser1}_${fetchedUser2}")
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .get();
    } else {
      return await firebaseFirestore
          .collection("chat")
          .doc("${fetchedUser1}_${fetchedUser2}")
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .get();
    }
  }
  Future<void> deleteMessage({required String chatRoomId, required String messageId}) async {
    await firebaseFirestore
        .collection("chat")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage({required String chatRoomId, required String messageId, required String newMessageText}) async {
    await firebaseFirestore
        .collection("chat")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId)
        .update({"msg": newMessageText});
  }
}

