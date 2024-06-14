
class ErrorMessages{
  static const Map<String, String> errorMessages = {
    "email-already-in-use": "The email address is already in use.",
    "invalid-email": "The email address is not valid, try again.",
    "operation-not-allowed": "Email/password accounts are not enabled.",
    "weak-password": "The password is too weak.",
    "user-disabled": "The user account has been disabled by an administrator.",
    "user-not-found": "There is no account corresponding to the given email address.",
    "wrong-password": "The password is invalid.",
  };

  static String getErrorMessage(String code) {
    return errorMessages[code] ?? "An unknown error occurred.";
  }
}