import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'expensemain.dart';
import 'deleteconfirmdialog.dart';
import 'editexpensetitle.dart';
import 'costContainerList.dart';

class ExpenseDetail extends StatefulWidget{
  Database database;
  ExpenseMain expense;
  ExpenseDetail({Key key, this.expense, this.database}):super(key: key);

  _myExpenseDetailState createState() => _myExpenseDetailState();

}


class _myExpenseDetailState extends State<ExpenseDetail>{
  bool backRefresh = false;
  CostListView costListView;
  @override
  Widget build(BuildContext context) {
    print("building detail");
    costListView = CostListView(expense: widget.expense,);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            print("Go Back");
            Navigator.of(context).pop(backRefresh);
          },
        ),
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(widget.expense.title),
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              ),
              Container(
                child: Text(widget.expense.date, style: TextStyle(fontSize: 10),),
                padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
              )
            ],
          )
        ),
        actions: [
          IconButton(
            onPressed: (){
              print("Edit Title");
              showDialog(
                context: context,
                builder: (BuildContext buildContext){
                  return EditExpenseTitle(expense: widget.expense);
                }
              ).then((value) async {
                print("Recvd Value: " + value.toString());
                if(value['title']!=null){
                  print("Refreshing");
                  widget.expense.title = value['title'];
                  await widget.database.update('expensemain', widget.expense.toMap(), where: 'id = ?', whereArgs: [widget.expense.id]);
                  backRefresh = true;
                  setState(() {

                  });
                }
              });
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
              onPressed: (){
                print("Delete Expense");
                showDialog(
                  context: context,
                  builder: (BuildContext buildContext){
                    return DeleteConfirmDialog(expenseTitle: widget.expense.title,);
                  }
                ).then((value) async{
                  if(value){
                    print("Deleting...");
                    await widget.database.delete('expensemain', where: 'id = ?', whereArgs: [widget.expense.id]);
                    await widget.database.rawQuery("drop table table" + widget.expense.id.toString());
                    Navigator.of(context).pop(true);
                  }
                });
              },
              icon: Icon(Icons.delete)
          ),
          IconButton(
            onPressed: (){
              print("Save Expense");
              widget.expense = costListView.getExpenseObect();
              Navigator.of(context).pop(false);
            },
            icon: Icon(Icons.done)
          ),
        ],
      ),
      body: costListView,
    );
  }
}