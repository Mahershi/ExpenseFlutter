import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'expensemain.dart';
import 'deleteconfirmdialog.dart';
import 'editexpensetitle.dart';
import 'costContainerList.dart';
import 'newcost.dart';

class ExpenseDetail extends StatefulWidget{
  Database database;
  ExpenseMain expense;
  ExpenseDetail({Key key, this.expense, this.database}):super(key: key);

  _myExpenseDetailState createState() => _myExpenseDetailState();

}


class _myExpenseDetailState extends State<ExpenseDetail>{
  bool backRefresh = false;
  bool loaded = false;
  CostListView costListView;
  Widget body;

  Future<bool> _onWillPop() async{
    Navigator.of(context).pop(backRefresh);
    return false;
  }

  Future<void> readCosts() async{
    ExpenseMain temp = widget.expense;
    widget.expense.costList.clear();
    List<Map> costs = await widget.database.rawQuery("Select * from " + widget.expense.tableName + " order by id desc");
    for(int i=0; i<costs.length; i++){
      widget.expense.costList.add(widget.expense.copyCosts(costs[i]));
    }
  }


  @override
  Widget build(BuildContext context) {
    print("building detail");
    if(!loaded){
      body = Center(
        child: CircularProgressIndicator(),
      );
      readCosts().then((value){
        print("Read Done");
        setState(() {
          loaded = true;
        });
      });
    }else{
      costListView = CostListView(expense: widget.expense, database: widget.database);
      body = costListView;
    }


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                showDialog(
                    context: context,
                    builder: (BuildContext buildContext){
                      return EditExpenseTitle(expense: widget.expense);
                    }
                ).then((value) async {
                  if(value['title']!=null){
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
                  showDialog(
                      context: context,
                      builder: (BuildContext buildContext){
                        return DeleteConfirmDialog(expenseTitle: widget.expense.title,);
                      }
                  ).then((value) async{
                    if(value){
                      print("delete true");
                      await widget.database.delete('expensemain', where: 'id = ?', whereArgs: [widget.expense.id]);
                      await widget.database.rawQuery("drop table table" + widget.expense.id.toString());
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                icon: Icon(Icons.delete)
            ),
            IconButton(
              //save button
                onPressed: () async{
                  print("Add new cost");
                  Map<String, dynamic> newCost = await showDialog(
                      context: context,
                      builder: (BuildContext buildContext){
                        return NewCost();
                      }
                  );
                  if(newCost != null){
                    print("Cost recv on Prev: " + newCost.toString());
                    /*int currentMax;
                    if(widget.expense.costList.isEmpty)
                      currentMax = 0;
                    else
                      currentMax = widget.expense.costList[0]['id'];
                    */
                    //newCost['id'] = currentMax+1;
                    newCost['id'] = await widget.database.insert(widget.expense.tableName, newCost);
                    print("New Cost: " + newCost.toString());
                    widget.expense.costList.insert(0, newCost);
                    widget.expense.show();
                    setState(() {
                      print("New Added, setting state");
                    });
                  }else{
                    print("Null");
                  }
                },
                icon: Icon(Icons.add)
            ),
          ],
        ),
        body: body,
      )
    );
  }

  /*Future<void> saveExpense() async{
    await widget.database.rawQuery("delete from " + widget.expense.tableName);
    for(Map m in widget.expense.costList){
      await widget.database.insert(widget.expense.tableName, m);
      //await widget.database.rawQuery("insert or replace into " + widget.expense.tableName + "(id, title, amount, ignore) values(\'" + m['id'].toString() + "\',\'" + m['title'] + "\',\'" + m['amount'].toString() + "\',\'" + m['ignore'].toString() + "\')");
    }
    print("Db updte complete");
  }*/
}