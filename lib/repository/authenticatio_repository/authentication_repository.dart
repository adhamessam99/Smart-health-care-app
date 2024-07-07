/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:healthcare/repository/authenticatio_repository/exception/signup_email_password_failure.dart';
import 'package:healthcare/screens/home_screen.dart';
import 'package:healthcare/screens/welcome_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setIntialScreen);
  }

  _setIntialScreen(User? user) {
    user == null
        ? Get.offAll(() => WelcomeScreen())
        : Get.offAll(() => HomeScreen());
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
          firebaseUser.value != null
        ? Get.offAll(() => HomeScreen())
        : Get.offAll(() => WelcomeScreen());



    } on FirebaseAuthException catch (e) {

      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      print('FIREBASE AUTH EXCEPTION - ${ex.messages}');
      throw ex;

    } catch (_) {
      final ex = SignUpWithEmailAndPasswordFailure();
      print('FIREBASE AUTH EXCEPTION - ${ex.messages}');
      throw ex;
    }
  }

  Future<void> LoginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
        firebaseUser.value != null
        ? Get.offAll(() => HomeScreen())
        : Get.offAll(() => WelcomeScreen());



    } on FirebaseAuthException catch (e) {

     

    } catch (_) {
      
    }
  }

  Future<void> Logout() async => await _auth.signOut();
}*/
