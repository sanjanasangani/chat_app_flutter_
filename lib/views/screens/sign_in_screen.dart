import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/fcm_helper.dart';
import '../../helper/firebase_auth_helper.dart';


class Sign_in extends StatefulWidget {
  const Sign_in({Key? key}) : super(key: key);

  @override
  State<Sign_in> createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  final GlobalKey<FormState> signupFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFromKey = GlobalKey<FormState>();

  TextEditingController signupemailController = TextEditingController();
  TextEditingController signuppasswordController = TextEditingController();

  TextEditingController signInemailController = TextEditingController();
  TextEditingController signInpasswordController = TextEditingController();

  String? email;
  String? password;
  String? fcmToken;

  int intialIndex = 0;
  @override
  initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    fcmToken = await FcmHelper.fcmHelper.getFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe8ebed),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 60,
          alignment: Alignment.bottomCenter,
          child: IndexedStack(
            index: intialIndex,
            children: [
              Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            width: 600,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  Image.asset("assets/images/friendship.png"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      Form(
                        key: signInFromKey,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffe1e2e3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800),
                                    )),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  decoration: const BoxDecoration(
                                      color: Color(0xfff5f8fd),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Your Email",
                                      prefixIcon: Icon(
                                        Icons.person,
                                      ),
                                    ),
                                    controller: signInemailController,
                                    onSaved: (newValue) {
                                      email = newValue;
                                    },
                                    validator: (value) => (value!.isEmpty)
                                        ? "Enter Your Email"
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  decoration: const BoxDecoration(
                                      color: Color(0xfff5f8fd),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Your Password",
                                      prefixIcon: Icon(
                                        Icons.lock_open,
                                      ),
                                    ),
                                    controller: signInpasswordController,
                                    onSaved: (newValue) {
                                      password = newValue;
                                    },
                                    validator: (value) => (value!.isEmpty)
                                        ? "Enter Your Email"
                                        : null,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                            child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.w500),
                        )),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              if (signInFromKey.currentState!.validate()) {
                                (signInFromKey.currentState!.save());

                                Get.back();
                                Map<String, dynamic> data =
                                    await FireBaseAuthHelper
                                        .fireBaseAuthHelper
                                        .signIn(
                                            email: email!, password: password!,fcmToken: fcmToken!);

                                if (data['user'] != null) {
                                  Get.snackbar(
                                    "Login Successfully",
                                    "Login Successfully",
                                    backgroundColor: Colors.green,
                                  );
                                  Get.offAllNamed('/Home_page');
                                } else {
                                  Get.snackbar(
                                    "Login Failed",
                                    "${data["msg"]}",
                                    backgroundColor: Colors.red,
                                  );
                                }
                                signInemailController.clear();
                                signInpasswordController.clear();
                                email = null;
                                password = null;
                              }
                            },
                            child: const Text("Sign In"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              Map<String, dynamic> data =
                                  await FireBaseAuthHelper.fireBaseAuthHelper
                                      .signInWithGoogle(fcmToken: fcmToken!);

                              if (data['user'] != null) {
                                Get.snackbar(
                                  "google Login Successfully",
                                  "Login Successfully",
                                  backgroundColor: Colors.green,
                                );
                                Get.toNamed('/Home_page');
                              } else {
                                Get.snackbar(
                                  "google Login Failed",
                                  "${data["msg"]}",
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            child: const Text("Google"),
                          ),
                          //     GestureDetector(
                          //       onTap: () async {
                          //         Map<String, dynamic> data =
                          //             await FireBaseAuthHelper.fireBaseAuthHelper
                          //                 .signInWithGoogle();
                          //         Get.back();
                          //         if (data['user'] != null) {
                          //           print('\nUser: ${data['user']}');
                          //           // if (await FireStoreHelper.fireStoreHelper.userExit()) {
                          //           //   Get.offAllNamed("/Home_page",arguments: data['user']);
                          //           // } else {
                          //           //   await FireStoreHelper.fireStoreHelper.createUser().then((value) {
                          //           //     Get.offAllNamed("/Home_page",arguments: data['user']);
                          //           //   });
                          //           // }
                          //           //
                          //           Get.snackbar(
                          //             'Successfully',
                          //             "Login Successfully",
                          //             backgroundColor: Colors.green,
                          //             snackPosition: SnackPosition.BOTTOM,
                          //             duration: const Duration(seconds: 2),
                          //           );
                          //           Get.offAllNamed("/Home_page",
                          //               arguments: data['user']);
                          //         } else {
                          //           Get.snackbar(
                          //             'Failed',
                          //             data['msg'],
                          //             backgroundColor: Colors.red,
                          //             snackPosition: SnackPosition.BOTTOM,
                          //             duration: const Duration(seconds: 2),
                          //           );
                          //         }
                          //         print("${data['user']}");
                          //       },
                          //       child: Container(
                          //           padding: const EdgeInsets.symmetric(
                          //               horizontal: 10, vertical: 5),
                          //           decoration: const BoxDecoration(
                          //               color: Color(0xfff5f8fd),
                          //               borderRadius:
                          //                   BorderRadius.all(Radius.circular(20)),
                          //               boxShadow: [
                          //                 BoxShadow(
                          //                     //Created this shadow for looking elevated.
                          //                     //For creating like a card.
                          //                     color: Colors.black12,
                          //                     offset: Offset(0.0, 18.0),
                          //                     blurRadius: 15.0),
                          //                 BoxShadow(
                          //                     color: Colors.black12,
                          //                     offset: Offset(0.0, -04.0),
                          //                     blurRadius: 10.0),
                          //               ]),
                          //           child: Row(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: [
                          //               const Text(
                          //                 "Sign In With",
                          //                 style: TextStyle(
                          //                     fontSize: 16,
                          //                     color: Colors.deepPurpleAccent,
                          //                     fontWeight: FontWeight.w700),
                          //               ),
                          //               Image.asset(
                          //                 "assets/images/google.png",
                          //                 height: 40,
                          //               )
                          //             ],
                          //           )),
                          //     ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  intialIndex = 1;
                                });
                              },
                              child: Container(
                                child: const Text("Register now",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.deepPurpleAccent)),
                              ),
                            )
                          ]),
                    ],
                  )),
              Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: signupFromKey,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Positioned(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      "assets/images/talking.png",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffe1e2e3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: const BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      controller: signupemailController,
                                      onSaved: (newValue) {
                                        email = newValue;
                                      },
                                      validator: (value) => (value!.isEmpty)
                                          ? "Enter Your Email"
                                          : null,
                                      decoration: const InputDecoration(
                                          hintText: "Email",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: const BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      controller: signuppasswordController,
                                      onSaved: (newValue) {
                                        password = newValue;
                                      },
                                      validator: (value) => (value!.isEmpty)
                                          ? "Enter Your password"
                                          : null,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                          hintText: "Password",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      //Raised Buttons of sigup will appear.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              if (signupFromKey.currentState!.validate()) {
                                (signupFromKey.currentState!.save());

                                Get.back();
                                Map<String, dynamic> data =
                                    await FireBaseAuthHelper
                                        .fireBaseAuthHelper
                                        .signUp(
                                            email: email!, password: password!);

                                if (data['user'] != null) {
                                  Get.snackbar(
                                    "Signup Successfully",
                                    "Signup Successfully",
                                    backgroundColor: Colors.green,
                                  );
                                  setState(() {
                                    intialIndex = 0;
                                  });
                                } else {
                                  Get.snackbar(
                                    "Signup Failed",
                                    "${data["msg"]}",
                                    backgroundColor: Colors.red,
                                  );
                                }
                                signuppasswordController.clear();
                                signupemailController.clear();
                                email = null;
                                password = null;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepPurpleAccent,
                              elevation: 13,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white70),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  intialIndex = 0;
                                });
                              },
                              child: Container(
                                child: const Text("Sign In",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.deepPurpleAccent,
                                        fontSize: 18)),
                              ),
                            )
                          ]),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:chat_app/utils/helper/firebase_auth_helper.dart';
//
// class Sign_in extends StatefulWidget {
//   const Sign_in({Key? key}) : super(key: key);
//
//   @override
//   State<Sign_in> createState() => _Sign_inState();
// }
//
// class _Sign_inState extends State<Sign_in> {
//   final GlobalKey<FormState> signupFromKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> signInFromKey = GlobalKey<FormState>();
//
//   TextEditingController signupemailController = TextEditingController();
//   TextEditingController signuppasswordController = TextEditingController();
//
//   TextEditingController signInemailController = TextEditingController();
//   TextEditingController signInpasswordController = TextEditingController();
//
//   String? email;
//   String? password;
//   String? fcmToken;
//
//   final TextEditingController EmailController = TextEditingController();
//   final TextEditingController UsernameController = TextEditingController();
//   final TextEditingController PasswordController = TextEditingController();
//
//   String Email = '';
//   String Username = '';
//   String Password = '';
//   int intialIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffe8ebed),
//       body: SingleChildScrollView(
//         child: Container(
//           height: MediaQuery.of(context).size.height - 60,
//           alignment: Alignment.bottomCenter,
//           child: IndexedStack(
//             index: intialIndex,
//             children: [
//               Container(
//                   padding: const EdgeInsets.all(30),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Stack(
//                         children: [
//                           Container(
//                             height: 180,
//                             width: 600,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child:
//                               Image.asset("assets/images/friendship.png"),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 60),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: const Color(0xffe1e2e3),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 5,
//                                 blurRadius: 7,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ]),
//                         child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 3),
//                                   child: const Text(
//                                     "Login",
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w800),
//                                   )),
//                               const SizedBox(height: 5),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 2, vertical: 5),
//                                 decoration: const BoxDecoration(
//                                     color: Color(0xfff5f8fd),
//                                     borderRadius:
//                                     BorderRadius.all(Radius.circular(20))),
//                                 child: TextFormField(
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: "Enter Your Email",
//                                     prefixIcon: Icon(
//                                       Icons.person,
//                                     ),
//                                   ),
//                                   controller: signInemailController,
//                                   onSaved: (newValue) {
//                                     email = newValue;
//                                   },
//                                   validator: (value) =>
//                                   (value!.isEmpty) ? "Enter Your Email" : null,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 2, vertical: 5),
//                                 decoration: const BoxDecoration(
//                                     color: Color(0xfff5f8fd),
//                                     borderRadius:
//                                     BorderRadius.all(Radius.circular(20))),
//                                 child: TextFormField(
//                                   decoration: const InputDecoration(
//                                     border: InputBorder.none,
//                                     hintText: "Enter Your Password",
//                                     prefixIcon: Icon(
//                                       Icons.lock_open,
//                                     ),
//                                   ),
//                                   controller: signInpasswordController,
//                                   onSaved: (newValue) {
//
//                                     password = newValue;
//                                   },
//                                   validator: (value) =>
//                                   (value!.isEmpty) ? "Enter Your Email" : null,
//                                 ),
//                               ),
//                             ]),
//                       ),
//                       const SizedBox(
//                         height: 25,
//                       ),
//                       Container(
//                         alignment: Alignment.centerRight,
//                         child: Container(
//                             child: const Text(
//                               "Forgot Password?",
//                               style: TextStyle(
//                                   color: Colors.deepPurpleAccent,
//                                   fontWeight: FontWeight.w500),
//                             )),
//                       ),
//                       const SizedBox(height: 25),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () async {
//                               Get.back();
//                               if (signInFromKey.currentState!.validate()) {
//                                 (signInFromKey.currentState!.save());
//
//                                 Get.back();
//                                 Map<String, dynamic> data = await FireBaseAuthHelper
//                                     .fireBaseAuthHelper
//                                     .signIn(email: email!, password: password!);
//
//                                 if (data['user'] != null) {
//                                   Get.snackbar(
//                                     "Login Successfully",
//                                     "Login Successfully",
//                                     backgroundColor: Colors.green,
//                                   );
//                                   Get.offAllNamed('/HomePage');
//                                 } else {
//                                   Get.snackbar(
//                                     "Login Failed",
//                                     "${data["msg"]}",
//                                     backgroundColor: Colors.red,
//                                   );
//                                 }
//                                 signInemailController.clear();
//                                 signInpasswordController.clear();
//                                 email = null;
//                                 password = null;
//                               }
//                             },
//                             child: const Text("Sign In"),
//                           ),
//                           const SizedBox(width: 10),
//                           // GestureDetector(
//                           //   onTap: () async {
//                           //     Map<String, dynamic> data =
//                           //         await FireBaseAuthHelper.fireBaseAuthHelper
//                           //             .signInWithGoogle();
//                           //     Get.back();
//                           //     if (data['user'] != null) {
//                           //       print('\nUser: ${data['user']}');
//                           //       // if (await FireStoreHelper.fireStoreHelper.userExit()) {
//                           //       //   Get.offAllNamed("/Home_page",arguments: data['user']);
//                           //       // } else {
//                           //       //   await FireStoreHelper.fireStoreHelper.createUser().then((value) {
//                           //       //     Get.offAllNamed("/Home_page",arguments: data['user']);
//                           //       //   });
//                           //       // }
//                           //       //
//                           //       Get.snackbar(
//                           //         'Successfully',
//                           //         "Login Successfully",
//                           //         backgroundColor: Colors.green,
//                           //         snackPosition: SnackPosition.BOTTOM,
//                           //         duration: const Duration(seconds: 2),
//                           //       );
//                           //       Get.offAllNamed("/Home_page",
//                           //           arguments: data['user']);
//                           //     } else {
//                           //       Get.snackbar(
//                           //         'Failed',
//                           //         data['msg'],
//                           //         backgroundColor: Colors.red,
//                           //         snackPosition: SnackPosition.BOTTOM,
//                           //         duration: const Duration(seconds: 2),
//                           //       );
//                           //     }
//                           //     print("${data['user']}");
//                           //   },
//                           //   child: Container(
//                           //       padding: const EdgeInsets.symmetric(
//                           //           horizontal: 10, vertical: 5),
//                           //       decoration: const BoxDecoration(
//                           //           color: Color(0xfff5f8fd),
//                           //           borderRadius:
//                           //               BorderRadius.all(Radius.circular(20)),
//                           //           boxShadow: [
//                           //             BoxShadow(
//                           //                 //Created this shadow for looking elevated.
//                           //                 //For creating like a card.
//                           //                 color: Colors.black12,
//                           //                 offset: Offset(0.0, 18.0),
//                           //                 blurRadius: 15.0),
//                           //             BoxShadow(
//                           //                 color: Colors.black12,
//                           //                 offset: Offset(0.0, -04.0),
//                           //                 blurRadius: 10.0),
//                           //           ]),
//                           //       child: Row(
//                           //         mainAxisAlignment: MainAxisAlignment.center,
//                           //         children: [
//                           //           const Text(
//                           //             "Sign In With",
//                           //             style: TextStyle(
//                           //                 fontSize: 16,
//                           //                 color: Colors.deepPurpleAccent,
//                           //                 fontWeight: FontWeight.w700),
//                           //           ),
//                           //           Image.asset(
//                           //             "assets/images/google.png",
//                           //             height: 40,
//                           //           )
//                           //         ],
//                           //       )),
//                           // ),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Don't have an account?"),
//                             const SizedBox(width: 10),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   intialIndex = 1;
//                                 });
//                               },
//                               child: Container(
//                                 child: const Text("Register now",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.deepPurpleAccent)),
//                               ),
//                             )
//                           ]),
//                     ],
//                   )),
//               Container(
//                   padding: const EdgeInsets.all(30),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Form(
//                         child: Column(
//                           children: [
//                             Stack(
//                               children: [
//                                 Positioned(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(50),
//                                     child: Image.asset(
//                                       "assets/images/talking.png",
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 40),
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: const Color(0xffe1e2e3),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.5),
//                                       spreadRadius: 5,
//                                       blurRadius: 7,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ]),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 5),
//                                     decoration: const BoxDecoration(
//                                         color: Color(0xfff5f8fd),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(20))),
//                                     child: TextFormField(
//                                       onSaved: (newValue) {
//                                         Username = newValue!;
//                                       },
//                                       controller: UsernameController,
//                                       decoration: const InputDecoration(
//                                           hintText: "Username",
//                                           border: InputBorder.none),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 5),
//                                     decoration: const BoxDecoration(
//                                         color: Color(0xfff5f8fd),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(20))),
//                                     child: TextFormField(
//                                       onSaved: (newValue) {
//                                         Email = newValue!;
//                                       },
//                                       controller: EmailController,
//                                       decoration: const InputDecoration(
//                                           hintText: "Email",
//                                           border: InputBorder.none),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 5),
//                                     decoration: const BoxDecoration(
//                                         color: Color(0xfff5f8fd),
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(20))),
//                                     child: TextFormField(
//                                       onSaved: (newValue) {
//                                         Password = newValue!;
//                                       },
//                                       controller: PasswordController,
//                                       obscureText: true,
//                                       decoration: const InputDecoration(
//                                           hintText: "Password",
//                                           border: InputBorder.none),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       //Raised Buttons of sigup will appear.
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               signupWithEmailPassword();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: Colors.deepPurpleAccent,
//                               elevation: 13,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 15, horizontal: 55),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 side: BorderSide(color: Colors.white70),
//                               ),
//                             ),
//                             child: const Text(
//                               "Sign Up",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           // InkWell(
//                           //   onTap: () async {
//                           //     Map<String, dynamic> data =
//                           //         await FireBaseAuthHelper.fireBaseAuthHelper
//                           //             .signInWithGoogle();
//                           //     if (data['user'] != null) {
//                           //       Get.snackbar(
//                           //         "Success",
//                           //         "SignIn Successfully...",
//                           //         backgroundColor: Colors.green,
//                           //         snackPosition: SnackPosition.BOTTOM,
//                           //       );
//                           //       Get.offNamed(
//                           //         "/Home_page",
//                           //         arguments: data['user'],
//                           //       );
//                           //     } else {
//                           //       Get.snackbar(
//                           //         "Failed",
//                           //         data['msg'],
//                           //         backgroundColor: Colors.redAccent,
//                           //         snackPosition: SnackPosition.BOTTOM,
//                           //       );
//                           //     }
//                           //   },
//                           //   child: Container(
//                           //       padding: const EdgeInsets.symmetric(
//                           //           horizontal: 10, vertical: 5),
//                           //       decoration: const BoxDecoration(
//                           //           color: Color(0xfff5f8fd),
//                           //           borderRadius:
//                           //               BorderRadius.all(Radius.circular(20)),
//                           //           boxShadow: [
//                           //             //For creating like a card.
//                           //             BoxShadow(
//                           //                 color: Colors.black12,
//                           //                 offset: Offset(0.0, 18.0),
//                           //                 blurRadius: 15.0),
//                           //             BoxShadow(
//                           //                 color: Colors.black12,
//                           //                 offset: Offset(0.0, -04.0),
//                           //                 blurRadius: 10.0),
//                           //           ]),
//                           //       child: Row(
//                           //         children: [
//                           //           const Text(
//                           //             "Sign Up With",
//                           //             style: TextStyle(
//                           //                 fontSize: 16,
//                           //                 color: Colors.deepPurpleAccent,
//                           //                 fontWeight: FontWeight.w700),
//                           //           ),
//                           //           Image.asset(
//                           //             "assets/images/google.png",
//                           //             height: 40,
//                           //           )
//                           //         ],
//                           //       )),
//                           // )
//                         ],
//                       ),
//                       const SizedBox(height: 25),
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Already have an account?"),
//                             const SizedBox(width: 10),
//                             InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   intialIndex = 0;
//                                 });
//                               },
//                               child: Container(
//                                 child: const Text("Sign In",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w900,
//                                         color: Colors.deepPurpleAccent,
//                                         fontSize: 18)),
//                               ),
//                             )
//                           ]),
//                     ],
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Future<void> signInWithEmailPassword() async {
//   //   Map<String, dynamic> data = await FireBaseAuthHelper.fireBaseAuthHelper
//   //       .signinWithEmailPassword(email: Email, password: Password);
//   //
//   //   if (data['user'] != null) {
//   //     Get.snackbar(
//   //       'Successfully',
//   //       "Successfully Login",
//   //       backgroundColor: Colors.green,
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       duration: const Duration(seconds: 2),
//   //     );
//   //     Get.toNamed("/HomePage");
//   //   } else {
//   //     Get.snackbar(
//   //       'Failed',
//   //       data["msg"] ?? 'Unknown error occurred',
//   //       backgroundColor: Colors.red,
//   //       snackPosition: SnackPosition.BOTTOM,
//   //       duration: const Duration(seconds: 2),
//   //     );
//   //   }
//   // }
//   //
//   Future<void> signupWithEmailPassword() async {
//     // Map<String, dynamic> data = await FireBaseAuthHelper.fireBaseAuthHelper
//     //     .signupWithEmailPassword(email: Email, password: Password);
//     //
//     // if (data['user'] != null) {
//     //   Get.snackbar(
//     //     'Successfully',
//     //     "Successfully Login",
//     //     backgroundColor: Colors.green,
//     //     snackPosition: SnackPosition.BOTTOM,
//     //     duration: const Duration(seconds: 2),
//     //   );
//     //   Get.toNamed("/Sign_in");
//     // } else {
//     //   Get.snackbar(
//     //     'Failed',
//     //     data["msg"] ?? 'Unknown error occurred',
//     //     backgroundColor: Colors.red,
//     //     snackPosition: SnackPosition.BOTTOM,
//     //     duration: const Duration(seconds: 2),
//     //   );
//     // }
//   }
// }
