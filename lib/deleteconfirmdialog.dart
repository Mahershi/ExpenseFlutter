import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatelessWidget{
  final String expenseTitle;
  DeleteConfirmDialog({Key key, this.expenseTitle}):super(key: key);
  @override
  Widget build(BuildContext buildContext){
    return AlertDialog(
      title: Text("Delete " + expenseTitle + "?"),
      actions: [
        FlatButton(
          child: Text("Affirmative"),
          onPressed: (){
            print("Yes Delete");
            Navigator.of(buildContext).pop(true);
          },
        ),
        FlatButton(
          child: Text("Negative"),
          onPressed: (){
            print("Dont Delete");
            Navigator.of(buildContext).pop(false);
          },
        )
      ],
    );
  }
}