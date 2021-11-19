import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/Components/Rounded_button.dart';
import 'package:flash_chat/functions/AlertButtonFunction.dart';
import 'package:flash_chat/local_auth/LocalAuthApi.dart';
import 'package:flash_chat/modalScreens/reset_password.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'home_screen.dart';
import 'package:flash_chat/generated/l10n.dart';
class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  User loggedUser;
  QueryDocumentSnapshot userInfo;
  String email;
  String password;
  bool showSpinner = false;


  @override
  void initState() {


    super.initState();
  }





  void getCurrentUser() async {
    final user = await _auth.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getData() async {
    StreamBuilder<QuerySnapshot>(
      // Here in the stream we get the user info from the database based on his email, we will get all of his information
        stream: FirebaseFirestore.instance
            .collection('User_Info')
            .where('email', isEqualTo: loggedUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            );
          }

          final user = snapshot.data.docs;
          userInfo = user[0];
          print(userInfo.get('darkMode'));


          return Text('');
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // backgroundColor: Color(0xffF4F9F9),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {

                  setState(() {
                    email = value;
                  });

                  },

                decoration: kTextFieldDecoration.copyWith(hintText: '${S.of(context).enterYourMail}' ,

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                fillColor: Colors.grey.shade800,
                filled: true),

              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,

                onChanged: (value){
                  setState(() {
                    password = value;
                  });
                },

                decoration: kTextFieldDecoration.copyWith(hintText: '${S.of(context).enterYourPass}',

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide( width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                    fillColor: Colors.grey.shade800,
                    filled: true),

              ),
              
              Row(children: [
                Expanded(child: SizedBox()),
                
                TextButton(onPressed: (){


                  showModalBottomSheet(
                    barrierColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) => ResetPassword()
                         );

                }, child: Text('${S.of(context).forgotPassword}')),
              ],),
              
             
              SizedBox(
                height: 24.0,
              ),





              paddingButton(Color(0xff01937C), '${S.of(context).logIn}', () async{


                setState(() {
                  showSpinner = true;
                });

                if(email == null || password == null){
                  email = '';
                  password = '';
                }
                final user = await _auth.signInWithEmailAndPassword(email: email, password: password).catchError((err) {

                  Platform.isIOS ? showIOSGeneralAlert(context,err.message): showGeneralErrorAlertDialog(context, 'Error', err.message);

                });

                try{
                if(user != null) {
                  getCurrentUser();
                  getData();

                  Navigator.of(context).pop();
                  Navigator
                      .of(context)
                      .pushReplacement(
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomeScreen(
                            loggedUser,
                          )
                      )
                  );

                }
                setState(() {
                  showSpinner = false;
                });}
                catch(e){
                  print(e);
                }
              },),


              paddingButton(Color(0xff01937C), 'Face ID', () async{

    final isAuthenticated = await LocalAuthApi.authenticate();

    if(isAuthenticated){
    Navigator
        .of(context)
        .pushReplacement(
    MaterialPageRoute(
    builder: (BuildContext context) => HomeScreen(
    loggedUser,
    )
    ));


        }
    }
    ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${S.of(context).dontHaveAccount}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  TextButton(onPressed: (){

                    Navigator.push( (context),
                        MaterialPageRoute(
                            builder: (BuildContext context) => RegistrationScreen()));


                  }, child: Text('${S.of(context).signUp}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff01937C),
                        fontSize: 15
                    ),))
                ],
              ),


            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
