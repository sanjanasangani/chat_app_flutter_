import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_helper.dart';

class FireBaseAuthHelper {
  FireBaseAuthHelper._();

  static final FireBaseAuthHelper fireBaseAuthHelper = FireBaseAuthHelper._();

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static final GoogleSignIn googleSignIn = GoogleSignIn();
  static User? currentUser;
  static final db = FirestoreHelper.firebaseFirestore;

  Future<Map<String, dynamic>> anonymousLogin() async {
    Map<String, dynamic> data = {};
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;
      data['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          data['msg'] = "Service Temporary Down";
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signUp(
      {required String email, required String password}) async {
    Map<String, dynamic> data = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      data['user'] = user;
      FirestoreHelper.firestoreHelper.addusers(
          data: {'email': email, 'uid': firebaseAuth.currentUser!.uid});
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          data["msg"] = "This service temporary down";
        case "weak-password":
          data["msg"] = "Password must be grater than 6 char.";
        case "email-already-in-use":
          data["msg"] = "User with this email id is already exists";
        default:
          data['msg'] = e.code;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signIn({required String email,required String password,required String fcmToken})async{

    Map<String,dynamic> data = { };
    try{
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      data['user'] = user;

      Map<String, dynamic> userData = {
        'email': user!.email,
        'uid': user.uid,
        'fcm-token': fcmToken,
      };
      bool isUserExists = await userExists();

      if (isUserExists == false) {
        await FirestoreHelper.firestoreHelper.addusers(data: userData);
      }
    }on FirebaseAuthException catch(e){
      switch(e.code){
        case "admin-restricted-operation":
          data['msg'] =  "This service temporary down";
          break;
        case "wrong-password":
          data['msg'] =  "Password is wrong";
          break;
        case "user-not-found":
          data['msg'] =  "User does not exists with this email id";
          break;
        case "user-disabled":
          data['msg'] =  "User is disabled ,contact admin";
          break;
        default:
          data['msg'] =  e.code;
          break;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signInWithGoogle({required String fcmToken}) async {
    Map<String,dynamic> data = { };

    try{
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =  await firebaseAuth.signInWithCredential(credential);

      User? user =userCredential.user;

      data['user'] = user;

      Map<String, dynamic> userData = {
        'email': user!.email,
        'uid': user.uid,
        'fcm-token': fcmToken,
      };

      bool isUserExists = await userExists();

      if (isUserExists == false) {
        await FirestoreHelper.firestoreHelper.addusers(data: userData);
      }
    }on FirebaseAuthException catch(e){
      switch(e.code){
        case "admin-restricted-operation":
          data['msg'] ="This service temporary down" ;
          break;
        case "weak-password":
          data['msg'] = "Password must be grater than 6 char.";
          break;
        case "email-already-in-use":
          data['msg'] = "User with this email id is already exists";
          break;
        default:
          data['msg'] = e.code;
      }
    }

    return data;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  fetchCurrentUser() {
    currentUser = firebaseAuth.currentUser!;
  }

  Future<bool> userExists() async {
    fetchCurrentUser();
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> collectionSnapShot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
        collectionSnapShot.docs;

    for (int i = 0; i < data.length; i++) {
      if (data[i]['uid'] == currentUser!.uid) {
        isUserExists = true;
        break;
      }
    }
    return isUserExists;
  }
}
