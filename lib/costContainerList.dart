import 'package:flutter/material.dart';
import 'expensemain.dart';
import 'package:sqflite/sqflite.dart';
import 'newcost.dart';

class CostListView extends StatefulWidget{
  int total = 0;
  ExpenseMain expense;
  Database database;
  CostListView({Key key, this.expense, this.database}):super(key: key);
  _myCostListViewState createState() => _myCostListViewState();

  ExpenseMain getExpenseObect(){
    return expense;
  }
}

class _myCostListViewState extends State<CostListView>{
  bool green = false;
  Widget mainBody;
  @override
  Widget build(BuildContext context) {
    print("Building cost list");
    for(Map current in widget.expense.costList){
      if(current['ignore'] == 0){
        widget.total += int.parse(current['amount'].toString());
      }
    }

    if(widget.expense.costList.isEmpty){
      mainBody = Center(
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(10)),
            child: FlatButton(
                child: Text(
                    "+ Add A Cost",
                    style: TextStyle(color: Colors.white)
                ),
                onPressed: () async {
                  print("Add new cost");
                  Map<String, dynamic> newCost = await showDialog(
                      context: context,
                      builder: (BuildContext buildContext){
                        return NewCost();
                      }
                  );
                  if(newCost != null){
                    print("Cost recv on Prev: " + newCost.toString());
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
                }
            )
        )
      );
    }else{
      mainBody = ListView.builder(
        itemBuilder: (BuildContext buildContext, int index){
          return getCostItemsContainerList()[index];
        },
        itemCount: widget.expense.costList.length,
        shrinkWrap: true,
      );
    }
    return Column(
      children: [
        Expanded(
          child: mainBody
        ),
        Container(
          color: Colors.pinkAccent,
          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  widget.total.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                )
              )
            ],
          )
        )
      ],
    );
  }

  List<Container> getCostItemsContainerList(){
    List<Container> costListContainer = [];
    Container container;
    Icon igIcon;
    Text amount;
    Text title;
    for(int i=0; i<widget.expense.costList.length; i++){
      Map current = widget.expense.costList[i];
      if(current['ignore'] == 1){
        igIcon = Icon(Icons.add, color: Colors.white38,);
        amount = Text(
          current['amount'].toString(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white38,
            fontWeight: FontWeight.normal
          ),
        );
        title = Text(
          current['title'],
          style: TextStyle(
              fontSize: 16,
              color: Colors.white38,
          ),
        );
      }else{
        igIcon = Icon(Icons.add_circle_outline, color: Colors.pinkAccent,);
        amount = Text(
          current['amount'].toString(),
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        );
        title = Text(
          current['title'],
          style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        );
      }
      container = Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.pinkAccent, width: 0.5))),
        child: Row(
          children: [
            Container(
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                iconSize: 17,
                onPressed: ()async{
                  print("Delete Cost");
                  widget.expense.costList.removeAt(i);
                  await widget.database.delete(widget.expense.tableName, where: 'id = ?', whereArgs: [current['id']]);
                  setState(() {
                    widget.total = 0;
                  });
                },
              ),
            ),
            Container(
                  child: Expanded(
                    child: title
                  ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
              child: amount,
            ),
            Container(
                child: IconButton(
                  icon: igIcon,
                  iconSize: 17,
                  onPressed: (){
                    widget.expense.costList[i]['ignore'] = 1 - widget.expense.costList[i]['ignore'];
                    print("New Ignore: " + widget.expense.costList[i]['ignore'].toString());
                    setState(() {
                      print("Reset cost list body");
                      widget.total = 0;
                    });
                  },
                )
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                iconSize: 17,
                onPressed: () async{
                  Map<String, dynamic> newCost = await showDialog(
                      context: context,
                      builder: (BuildContext buildContext){
                        return NewCost(cost: widget.expense.costList[i]);
                      }
                  );
                  if(newCost != null){
                    print("Cost recv on Prev: " + newCost.toString());
                    newCost['id'] = await widget.database.update(widget.expense.tableName, newCost, where: 'id = ?', whereArgs: [current['id']]);
                    print("New Cost: " + newCost.toString());
                    widget.expense.costList.removeAt(i);
                    widget.expense.costList.insert(0, newCost);
                    widget.expense.show();
                    setState(() {
                      print("New Added, setting state");
                    });
                  }else{
                    print("Null");
                  }
                }
              )
            )
          ],
        ),
      );
      costListContainer.add(container);
    }
    print("Size: " + costListContainer.length.toString());
    return costListContainer;
  }
}