import 'package:expense/expensedetail.dart';
import 'package:expense/expensemain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditExpenseTitle extends StatelessWidget{
  final ExpenseMain expense;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titlecontroller = TextEditingController();
  EditExpenseTitle({Key key, this.expense}):super(key: key);
  final Map<String, dynamic> result = Map<String, dynamic>();
  @override
  Widget build(BuildContext context) {
    titlecontroller.text = expense.title;
    return AlertDialog(
      title: Text("Edit Expense Title"),
      content: Builder(builder: (context){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        child: TextFormField(
                          controller: titlecontroller,
                          decoration: InputDecoration(
                              hintText: "Expense Title"
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]+"))
                          ],
                          validator: (value){
                            if(value.isEmpty){
                              return "Enter Title";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                )
            )
          ],
        );
      }),
      actions: [
        FlatButton(
          child: Text("Save"),
          onPressed: (){
            expense.title = titlecontroller.text;
            result['title'] = expense.title;
            result['refresh'] = 'true';
            print("Save title");
            print("Result: " + result.toString());
            Navigator.of(context).pop(result);
          },
        ),
        FlatButton(
          child: Text("Discard"),
          onPressed: (){
            result['refresh'] = 'false';
            print("Discard Title");
            print("Result: " + result.toString());
            _formKey.currentState.reset();
            Navigator.of(context).pop(result);
          },
        )
      ],
    );
  }


}