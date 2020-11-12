import 'package:flutter/material.dart';
import 'expensemain.dart';

class CostListView extends StatefulWidget{
  int total = 0;
  ExpenseMain expense;
  CostListView({Key key, this.expense}):super(key: key);
  _myCostListViewState createState() => _myCostListViewState();

  ExpenseMain getExpenseObect(){
    return expense;
  }
}

class _myCostListViewState extends State<CostListView>{
  bool green = false;
  @override
  Widget build(BuildContext context) {
    print("Building cost list");
    for(Map current in widget.expense.costList){
      if(current['ignore'] == 0){
        widget.total += current['amount'];
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Text(
                  "Items: " + widget.expense.costList.length.toString(),
                  style: TextStyle(
                      fontSize: 18,
                  ),
                )
            ),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.add_box),
                iconSize: 30,
              )
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext buildContext, int index){
              return getCostItemsContainerList()[index];
            },
            itemCount: 3,
            shrinkWrap: true,
          )
        ),
        Container(
          color: Colors.lightBlueAccent,
          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
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
                      fontWeight: FontWeight.bold
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
    if(green){
      igIcon = Icon(Icons.add_circle_outline, color: Colors.green,);
    }else{
      igIcon = Icon(Icons.add, color: Colors.grey,);
    }

    for(int i=0; i<3; i++){
      //Map current = widget.expense.costList[i];
      container = Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
        child: Row(
          children: [
            Container(
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  print("Delete Cost");
                },
              ),
            ),
            Container(
              child: Expanded(
                  child: Text(
                    "Heello",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  )
              ),
            ),
            Container(
                child: IconButton(
                  icon: igIcon,
                  onPressed: (){
                    //widget.expense.costList[i]['ignore'] = - widget.expense.costList[i]['ignore'];
                    //print("New Ignore: " + widget.expense.costList[i]['ignore'].toString());
                    setState(() {
                      green = !green;
                      print("Reset cost list body");
                      widget.total = 0;
                    });
                  },
                )
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
              child: Text(
                "1000",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      );
      costListContainer.add(container);
    }
    print("Size: " + costListContainer.length.toString());
    return costListContainer;
  }

  /*List<Container> getCostItemsContainerList(){
    List<Container> costListContainer = [];
    Container container;
    Icon igIcon;

    for(int i=0; i<widget.expense.costList.length; i++){
      Map current = widget.expense.costList[i];
      if(current['ignore'] == 1){
        igIcon = Icon(Icons.add, color: Colors.grey,);
      }else{
        igIcon = Icon(Icons.add_circle_outline, color: Colors.green,);
      }
      container = Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
        child: Row(
          children: [
            Container(
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  print("Delete Cost");
                },
              ),
            ),
            Container(
                  child: Expanded(
                    child: Text(
                      current['title'],
                      style: TextStyle(
                          fontSize: 18
                      ),
                    )
                  ),
            ),
            Container(
                child: IconButton(
                  icon: igIcon,
                  onPressed: (){
                    widget.expense.costList[i]['ignore'] = - widget.expense.costList[i]['ignore'];
                    print("New Ignore: " + widget.expense.costList[i]['ignore'].toString());
                    setState(() {
                      print("Reset cost list body");
                      widget.total = 0;
                    });
                  },
                )
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
              child: Text(
                current['amount'].toString(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      );
      costListContainer.add(container);
    }
    print("Size: " + costListContainer.length.toString());
    return costListContainer;
  }*/
}