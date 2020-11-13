import 'package:flutter/material.dart';

class ConfirmBack extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Discard Changes?"),
      actions: [
        FlatButton(
          child: Text("Save Changes"),
          onPressed: (){
            Navigator.of(context).pop(true);
          },
        ),
        FlatButton(
          child: Text("Discard Changes"),
          onPressed: (){
            Navigator.of(context).pop(false);
          },
        )
      ],
    );
  }
}