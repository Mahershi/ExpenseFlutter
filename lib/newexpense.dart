import 'package:expense/expensedetail.dart';
import 'package:expense/expensemain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

String capitalize(String input) => input[0].toUpperCase() + input.substring(1);

class NewExpenseDialog extends StatelessWidget{
  Database database;
  TextEditingController titlecontroller = TextEditingController();
  NewExpenseDialog({Key key, this.database}):super(key: key);
  var _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Expense",),
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
                          textCapitalization: TextCapitalization.sentences,
                          autofocus: true,
                          controller: titlecontroller,
                          decoration: InputDecoration(
                              hintText: "Expense Title",
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.pinkAccent
                                  )
                              )
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
              DateTime now = DateTime.now();
              String date = now.day.toString() + "/" + now.month.toString() + "/" + now.year.toString();
              String title = capitalize(titlecontroller.text);
              int tableno = await Sqflite.firstIntValue(await database.rawQuery("Select max(id) from expensemain"));
              if(tableno == null)
                tableno = 0;
              tableno++;
              print(tableno);

              String tempTable = "t";
              var newExpense = ExpenseMain(title, tempTable, date.toString());

              newExpense.id = await database.insert('expensemain', newExpense.toMap());
              String tablename = "table" + newExpense.id.toString();
              newExpense.tableName = tablename;
              await database.update('expensemain', newExpense.toMap(), where: 'id = ?', whereArgs: [newExpense.id]);
              String query = "create table " + tablename + " (id integer primary key autoincrement, title text, amount integer, ignore integer)";
              await database.execute(query);
              
              List<Map> result = await database.rawQuery("Select name from sqlite_master where type='table'");
              for(Map m in result){
                print(m.toString());
              }

              result = await database.rawQuery("Select * from expensemain order by id desc");
              for(Map m in result){
                print(m.toString());
              }
              print("Sending exp");
              Navigator.of(context).pop(newExpense);
              //Navigator.push(context, new MaterialPageRoute(builder: (BuildContext buildContext) => new ExpenseDetail(expense: newExpense, database: database,)));

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
            Navigator.of(context).pop(null);
          },
          child: Text("Discard")
        )
      ],
    );
  }

}