import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/screens/doc_home_page.dart';
import 'package:healthcare/screens/home_screen.dart';
import 'package:healthcare/screens/sign_up_screen.dart';
import 'package:healthcare/widgets/navbar.dart';
import 'package:healthcare/widgets/navbar_roots.dart';
import 'package:get/get.dart';
import 'package:healthcare/controller/signin_controller.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


class loginScreen extends StatefulWidget {
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool passToggle = true;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Login'),
      ),
      body: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    "images/bck1.png",
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Enter Email"),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: password,
                    obscureText: passToggle,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Enter Password"),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            passToggle = !passToggle;
                          });
                        },
                        child: passToggle
                            ? Icon(CupertinoIcons.eye_slash_fill)
                            : Icon(CupertinoIcons.eye_fill),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () async {
                      try {
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email.text,
                          password: password.text,
                        );

                        final patientQuery = await FirebaseFirestore.instance.collection('Patients')
                          .where('email', isEqualTo: email.text)
                          .get();

                        final doctorQuery = await FirebaseFirestore.instance.collection('Doctors')
                          .where('email', isEqualTo: email.text)
                          .get();

                        if (patientQuery.docs.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavBarRoots(),
                            ),
                          );
                        } else if (doctorQuery.docs.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NavBar()),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'Email or Password May be Incorrect',
                        ).show();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have any account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'sign_up_screen');
                      },
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}