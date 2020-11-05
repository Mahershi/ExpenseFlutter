import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'expensemain.dart';

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
  print("Count: " + ExpenseMain.count.toString());

  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  final String title = "Expense";
  @override
  Widget build(BuildContext buildContext){
    return MaterialApp(
      home: HomePage(title: title),
      title: title,
    );
  }
}

class HomePage extends StatefulWidget{
  final String title;
  HomePage({Key key, this.title}):super(key: key);
  _myHomePageState createState() => _myHomePageState();
}

class _myHomePageState extends State<HomePage>{
  List<Map> expenseList = [];
  List<Row> expenseRowList = [];

  Widget refresh, mainBody;
  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    mainBody = Container(
        child: Text("Empty"),
      alignment: Alignment.center,
    );
    refresh = Tooltip(
      message: "Refresh",
      child: FlatButton(
        child: Icon(Icons.refresh),
      ),
    );
    if(!loaded){
      refresh = CircularProgressIndicator();
      refreshList().then((value) {
        setState((){
          loaded = true;
        });
      });
    }
    if(expenseList.isNotEmpty){
      mainBody = Container(child: Text("Not Empty"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5),
            child: refresh,
          ),
          FloatingActionButton(
            tooltip: "New Expense",
            child: Icon(Icons.add),
            onPressed: (){
              print("Button Pressed");
            },
          ),
          mainBody
        ],
      )
    );
  }

  Future<void> refreshList() async {
    print("Calling refresh");
    ExpenseMain.count = Sqflite.firstIntValue(await database.rawQuery("Select count(*) from expensemain"));
    print("Count: " + ExpenseMain.count.toString());
    expenseList.clear();
    expenseList = await database.rawQuery("Select * from expensemain order by id desc");

    print("Result Rows----------------------------------------------");
    for(Map m in expenseList){
      print(m.toString());
      //expenseRowList.add(listToRow(m));
    }
  }

  Row listToRow(Map<String, dynamic> map){
    Row r;
    //Implementation

    return r;
  }
}