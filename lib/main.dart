import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare/firebase_options.dart';
import 'package:healthcare/repository/authenticatio_repository/authentication_repository.dart';
import 'package:healthcare/screens/home_screen.dart';
import 'package:healthcare/screens/login_screen.dart';
import 'package:healthcare/screens/sign_up_screen.dart';
import 'package:healthcare/screens/welcome_screen.dart';
import 'package:healthcare/widgets/navbar_roots.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState(){
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:FirebaseAuth.instance.currentUser==null?  WelcomeScreen():NavBarRoots(),
      routes: {'sign_up_screen': (context) => SignUpScreen(),
        'login_screen': (context) => loginScreen(),
        'welcome_screen': (context) => WelcomeScreen(),
        'home_screen': (context) => HomeScreen()},
    );
  }
}