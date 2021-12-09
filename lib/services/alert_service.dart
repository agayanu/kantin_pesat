import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertService {
  void showAlert(
      BuildContext context, String title, String desc, VoidCallback onCancel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onCancel,
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void showSignOut(BuildContext context, String title, String desc,
      VoidCallback onSignOut, VoidCallback onCancel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onSignOut,
            child: const Text('Ya'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            onPressed: onCancel,
            child: const Text('Tidak'),
          ),
        ],
      ),
    );
  }
}
