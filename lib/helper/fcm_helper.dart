import 'package:firebase_messaging/firebase_messaging.dart';

class FcmHelper{
  FcmHelper._();

  static final FcmHelper fcmHelper =  FcmHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFcmToken()async{
    String? token = await firebaseMessaging.getToken();

    return token;
  }
}