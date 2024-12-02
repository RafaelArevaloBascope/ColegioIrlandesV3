import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GlobalMethods {

//Definir colores App
  static const Color primaryColor = Color.fromARGB(255, 0, 62, 137);
  static const Color secondaryColor =  Color.fromARGB(255, 227, 233, 244);

  //**SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  //**Toast sin Context */
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFF7E1670),
      textColor: Colors.white,
    );
  }

  //**Toast
  //*?showToastWithIcon(context, Icons.error_outline, "No se encontró ningún resultado.");
  static void showToastWithIcon(BuildContext context, IconData icon, String message) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static void showAlertDialog(BuildContext context, String successMessage) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(AppLocalizations.of(context)!.cancel_prompt),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(AppLocalizations.of(context)!.accept_prompt),
    onPressed:  () {
      showSuccessSnackBar(context, successMessage);
      Navigator.pushNamed(context, '/home');
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(AppLocalizations.of(context)!.alert_confirmation),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
}