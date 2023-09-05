import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/themeprovider.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import '../../helper/firebase_auth_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        actions: [
          TextButton(
            onPressed: () {
              image_pick(ImageSource.camera);
              Get.back();
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              image_pick(ImageSource.gallery);
              Get.back();
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, size: 25),
        ),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: const [
          Icon(
            Icons.search,
          ),
          SizedBox(
            width: 10,
          ),
        ],
        backgroundColor: Provider.of<ThemeProvider>(context, listen: true)
                .changethemeModel
                .isDark
            ? Colors.black
            : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            BigUserCard(
              backgroundColor: Colors.red,
              userName: "${FirebaseAuth.instance.currentUser!.displayName}",

              userProfilePic:  image != null
                  ? FileImage(image!)
                  : (FirebaseAuth.instance.currentUser!.photoURL != null
                  ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!) as ImageProvider
                  : const AssetImage('assets/images/google.png')),
              cardActionWidget: SettingsItem(
                icons: Icons.edit,
                iconStyle: IconStyle(
                  withBackground: true,
                  borderRadius: 50,
                  backgroundColor: Colors.yellow[600],
                ),
                title: "Modify",
                subtitle: "Tap to change your data",
                onTap: () {
                  print("OK");
                },
              ),
            ),
            SettingsGroup(
              items: [
                SettingsItem(
                  onTap: () {},
                  icons: CupertinoIcons.pencil_outline,
                  iconStyle: IconStyle(),
                  title: 'Appearance',
                  subtitle: "Make Chat app yours",
                ),
                SettingsItem(
                  onTap: () {},
                  icons: Icons.dark_mode_rounded,
                  iconStyle: IconStyle(
                    iconsColor: Colors.white,
                    withBackground: true,
                    backgroundColor: Colors.red,
                  ),
                  title: 'Dark mode',
                  subtitle: "Automatic",
                  trailing: Switch.adaptive(
                    value: Provider.of<ThemeProvider>(context, listen: true)
                                        .changethemeModel
                                        .isDark,
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                                          .chnageTheme();
                    },
                  ),
                ),
              ],
            ),
            SettingsGroup(
              items: [
                SettingsItem(
                  onTap: () {},
                  icons: Icons.info_rounded,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'About',
                  subtitle: "Learn more about Chat app",
                ),
              ],
            ),
            // You can add a settings title
            SettingsGroup(
              settingsGroupTitle: "Account",
              items: [
                SettingsItem(
                  onTap: () {
                    FireBaseAuthHelper.fireBaseAuthHelper.signOut();
                    Get.offNamedUntil("/Sign_in", (route) => false);
                  },
                  icons: Icons.exit_to_app_rounded,
                  title: "Sign Out",
                ),
                SettingsItem(
                  onTap: () {},
                  icons: CupertinoIcons.delete_solid,
                  title: "Delete account",
                  titleStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
      // body: Container(
      //   color: Provider.of<ThemeProvider>(context, listen: true)
      //           .changethemeModel
      //           .isDark
      //       ? Colors.black
      //       : Colors.white,
      //   child: Padding(
      //     padding: const EdgeInsets.all(12),
      //     child: Column(
      //       children: [
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(
      //                 left: 10,
      //               ),
      //               child: Text(
      //                 ("Language"),
      //                 style:
      //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //               ),
      //             ),
      //             IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward))
      //           ],
      //         ),
      //         const SizedBox(
      //           height: 15,
      //         ),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(
      //                 left: 10,
      //               ),
      //               child: Text(
      //                 ("Light Mode"),
      //                 style:
      //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //               ),
      //             ),
      //             Switch(
      //               value: Provider.of<ThemeProvider>(context, listen: true)
      //                   .changethemeModel
      //                   .isDark,
      //               onChanged: (value) {
      //                 Provider.of<ThemeProvider>(context, listen: false)
      //                     .chnageTheme();
      //               },
      //             )
      //           ],
      //         ),
      //         const SizedBox(
      //           height: 15,
      //         ),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(
      //                 left: 10,
      //               ),
      //               child: Text(
      //                 ("Notification"),
      //                 style:
      //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //               ),
      //             ),
      //             IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward))
      //           ],
      //         ),
      //         const SizedBox(
      //           height: 15,
      //         ),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(
      //                 left: 10,
      //               ),
      //               child: Text(
      //                 ("Account"),
      //                 style:
      //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //               ),
      //             ),
      //             IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward))
      //           ],
      //         ),
      //         const SizedBox(
      //           height: 15,
      //         ),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             const Padding(
      //               padding: EdgeInsets.only(
      //                 left: 10,
      //               ),
      //               child: Text(
      //                 ("Help"),
      //                 style:
      //                     TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //               ),
      //             ),
      //             IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward))
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
  }
}
