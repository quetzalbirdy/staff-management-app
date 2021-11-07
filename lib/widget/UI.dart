import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UI
{
  static Widget buildSnackbar(String message) {
    return SnackBar(
      content: Text(message),
    );
  }
//  void showAlert(){
//
//  }

  static Future<void> showAlert(BuildContext context,String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alephants'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static showSnacBar(BuildContext context,String message){
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }


}