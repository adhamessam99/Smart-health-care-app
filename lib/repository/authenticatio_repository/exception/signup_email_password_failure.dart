/*class SignUpWithEmailAndPasswordFailure {
  final String messages;

  SignUpWithEmailAndPasswordFailure(
      [this.messages = "An unknown error occured"]);

  factory SignUpWithEmailAndPasswordFailure.code(String code) {
    switch (code) {
      case "weak password":
        return  SignUpWithEmailAndPasswordFailure(
            "please enter strong password. ");
      case "invalid-email":
        return  SignUpWithEmailAndPasswordFailure(
            "email is not valid. ");
      case "email-already-in-use":
        return  SignUpWithEmailAndPasswordFailure(
            "an account already exist with this email. ");
      case "operation-not-allowed":
        return  SignUpWithEmailAndPasswordFailure(
            "operation is not allowed. please contact support. ");
      case "user-disabled":
        return  SignUpWithEmailAndPasswordFailure(
            "this user has been disabled .please contact support for help");
      default:
        return  SignUpWithEmailAndPasswordFailure();
    }
  }
}*/
