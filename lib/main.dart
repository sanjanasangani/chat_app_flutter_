import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat_s/views/screens/chating_screen.dart';
import 'package:we_chat_s/views/screens/home_page.dart';
import 'package:we_chat_s/views/screens/setting_page.dart';
import 'package:we_chat_s/views/screens/sign_in_screen.dart';
import 'controller/provider/themeprovider.dart';
import 'firebase_options.dart';
import 'helper/apptheme.dart';
import 'modals/theme_model.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkTheme = prefs.getBool('isDark') ?? false;
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ThemeProvider(
                  changethemeModel: ThemeModel(isDark: isDarkTheme))),
        ],
        builder: (context, _) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lighttheme,
            darkTheme: AppTheme.Darktheme,
            themeMode: (Provider.of<ThemeProvider>(context)
                .changethemeModel
                .isDark ==
                false)
                ? ThemeMode.light
                : ThemeMode.dark,
            initialRoute: "/Sign_in",
            getPages: [
              GetPage(
                name: "/Sign_in",
                page: () => Sign_in(),
              ),
              GetPage(
                name: "/Home_page",
                page: () => HomePage(),
              ),
              GetPage(
                name: "/chat_page",
                page: () => chatpage(),
              ),
              GetPage(
                name: "/SettingsPage",
                page: () => SettingsPage(),
              ),
            ],
          );
        }),
  );
}
