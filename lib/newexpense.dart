import 'package:expense/expensedetail.dart';
import 'package:expense/expensemain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class NewExpenseDialog extends StatelessWidget{
  Database database;
  TextEditingController titlecontroller = TextEditingController();
  NewExpenseDialog({Key key, this.database}):super(key: key);
  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Expense"),
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
          onPressed: () async {
            print("Save");
            if(_formKey.currentState.validate()){
              print("Correct");
              DateTime now = DateTime.now();
              String date = now.day.toString() + "/" + now.month.toString() + "/" + now.year.toString();
              print("Dte: " + date);
              String title = titlecontroller.text;
              print("Titel: " + title);
              int tableno = await Sqflite.firstIntValue(await database.rawQuery("Select max(id) from expensemain"));
              if(tableno == null)
                tableno = 0;
              tableno++;
              print(tableno);
              String tablename = "table" + tableno.toString();
              print("Tablename: " + tablename);

              var newExpense = ExpenseMain(title, tablename, date.toString());

              newExpense.id = await database.insert('expensemain', newExpense.toMap());
              print("New Expense: ");
              newExpense.show();

              String query = "create table " + tablename + " (id integer primary key autoincrement, title text, cost integer, ignore integer, date text)";
              await database.execute(query);
              
              List<Map> result = await database.rawQuery("Select name from sqlite_master where type='table'");
              for(Map m in result){
                print(m.toString());
              }

              result = await database.rawQuery("Select * from expensemain order by id desc");
              for(Map m in result){
                print(m.toString());
              }
              Navigator.of(context).pop(true);
             // Navigator.pushNamed(context, ExpenseMain());
             Navigator.push(context, new MaterialPageRoute(builder: (BuildContext buildContext) => new ExpenseDetail(expense: newExpense, database: database,)));
            }else{
              print("Incorredt");
            }

          },
          child: Text("Save")
        ),
        FlatButton(
          onPressed: (){
            print("Discard");
            _formKey.currentState.reset();
            Navigator.of(context).pop(false);
          },
          child: Text("Discard")
        )
      ],
    );
  }

}