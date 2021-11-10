import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flash_chat/screens/settings_screen.dart';
import 'package:flash_chat/them/darkThem.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/register_user_info.dart';

import 'package:firebase_auth/firebase_auth.dart';


void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    User loggedUser;
    QueryDocumentSnapshot userInfo;

    return MaterialApp(



      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        RegisterUserInfo.id: (context) => RegisterUserInfo(),
        HomeScreen.id: (context) => HomeScreen(loggedUser),
        SettingScreen.id: (context) => SettingScreen(userInfo)




      },
    );
  }
}
