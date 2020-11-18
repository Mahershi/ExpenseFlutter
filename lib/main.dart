import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'expensemain.dart';
import 'newexpense.dart';
import 'deleteconfirmdialog.dart';
import 'expensedetail.dart';

Database database;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var dbpath = await getDatabasesPath();
  String path = join(dbpath, 'expense.db');
  database = await openDatabase(
    path,
    version: 1,
    onCreate: (database, version) async{
      return database.execute("CREATE TABLE expensemain (id INTEGER PRIMARY KEY autoincrement, title TEXT, tablename TEXT, date TEXT)");
    }
  );

  ExpenseMain.count = Sqflite.firstIntValue(await database.rawQuery("Select count(*) from expensemain"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  final String title = "Expense";
  @override
  Widget build(BuildContext buildContext){
    return MaterialApp(
      home: HomePage(title: title),
      title: title,
      routes: {
        'expensedetail': (BuildContext buildContext) => new ExpenseDetail(),
      },
    );
  }
}

class HomePage extends StatefulWidget{
  final String title;
  HomePage({Key key, this.title}):super(key: key);
  _myHomePageState createState() => _myHomePageState();
}

class _myHomePageState extends State<HomePage>{
  BuildContext context;
  List<Map> expenseList = [];
  List<Container> expenseTileList = [];
  List<ExpenseMain> expenses = [];

  Widget refresh, mainBody, progressWidget;
  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    print("Building");
    progressWidget = Container();
    mainBody = Container(
        child: Text("Empty"),
      alignment: Alignment.center,
    );
    refresh = IconButton(
        icon: Icon(Icons.refresh),
        onPressed: (){
          setState(() {
            loaded = false;
          });
        },
    );
    if(!loaded){
      refreshList().then((value) {
        setState((){
          loaded = true;
        });
      });
    }
    if(expenseList.isNotEmpty){
      mainBody = ListView.builder(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        itemBuilder: (BuildContext buildContext, int index){
          return expenseTileList[index];
        },
        shrinkWrap: true,
        itemCount: expenseTileList.length,
        physics: NeverScrollableScrollPhysics(),
      );
   }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          refresh
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            progressWidget,
            mainBody
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "New Expense",
        child: Icon(Icons.add),
        onPressed: () async{
          showDialog(context: context, builder: (BuildContext buildContext){
            return NewExpenseDialog(database: database,);
          }).then((value){

            if(value != null){
              setState(() {
                loaded = false;
              });
              print("New EXP SHOW: ");
              value.show();
              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext buildContext) => new ExpenseDetail(expense: value, database: database,))).then((value){
                print("Back: " + value.toString());
              });
            }else{
              print("Not");
            }
          });
        },
      ),
    );
  }

  Future<void> refreshList() async {
    progressWidget = LinearProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent),);
    ExpenseMain.count = Sqflite.firstIntValue(await database.rawQuery("Select count(*) from expensemain"));
    expenseList.clear();
    expenseTileList.clear();
    expenseList.addAll(await database.rawQuery("Select * from expensemain order by id desc"));
    expenses.clear();
    print("Result Rows----------------------------------------------");
    print(expenseList.length.toString());
    ExpenseMain temp;
    for(Map m in expenseList){
      temp = ExpenseMain.fromMap(m);
      expenses.add(temp);
      expenseTileList.add(listToTile(temp));
    }

  }

  Container listToTile(ExpenseMain expense){
    Container container = Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
      padding: EdgeInsets.fromLTRB(9, 14, 5, 5),
      child: InkWell(
        onTap: (){
          print("Tapped");
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext buildContext) => new ExpenseDetail(expense: expense, database: database,)
              )
          ).then((value){
            print("Back: " + value.toString());
            if(value){
              setState(() {
                loaded = false;
              });
            }
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          expense.title,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                        child: Text(expense.date, style: TextStyle(fontSize: 11),),
                      ),
                    ]
                )
              )
            ),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async{
                  print("Pressed Delete");
                  showDialog(context: context, builder: (BuildContext buildContext){
                    return DeleteConfirmDialog(expenseTitle: expense.title);
                  }).then((value) async{
                    if(value){
                      print("Deleting...");

                      await database.delete('expensemain', where: 'id = ?', whereArgs: [expense.id]);
                      await database.rawQuery("drop table table" + expense.id.toString());

                      print("\n\nTable list");
                      List<Map> result = await database.rawQuery("Select name from sqlite_master where type='table'");
                      for(Map m in result){
                        print(m.toString());
                      }

                      print("\n\nExpense main content");
                      result = await database.rawQuery("Select * from expensemain order by id desc");
                      for(Map m in result){
                        print(m.toString());
                      }
                      setState(() {
                        loaded = false;
                      });
                    }
                  });
                },
              )
            ),
          ],
        )
      )
    );

    return container;
  }
}