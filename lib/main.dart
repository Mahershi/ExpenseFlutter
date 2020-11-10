import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'expensemain.dart';
import 'newexpense.dart';
import 'deleteconfirmdialog.dart';

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
  BuildContext context;
  List<Map> expenseList = [];
  List<Container> expenseTileList = [];

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
      print("Not loaded");

      refreshList().then((value) {
        print("refresh end");
        setState((){
          loaded = true;
          print("Load finish setstate");
        });
      });
    }
    if(expenseList.isNotEmpty){
      mainBody = ListView.builder(
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
          print("Add new");
          await showDialog(context: context, builder: (BuildContext buildContext){
            return NewExpenseDialog(database: database,);
          }).then((value){
            print("Then called on dialog box");
            if(value){
              print("Refreshing");
              setState(() {
                loaded = false;
              });
            }

          });
        },
      ),
    );
  }

  Future<void> refreshList() async {
    progressWidget = LinearProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent),);
    print("Calling refresh");
    ExpenseMain.count = Sqflite.firstIntValue(await database.rawQuery("Select count(*) from expensemain"));
    print("Count: " + ExpenseMain.count.toString());
    expenseList.clear();
    expenseTileList.clear();
    expenseList.addAll(await database.rawQuery("Select * from expensemain order by id desc"));

    print("Result Rows----------------------------------------------");
    print(expenseList.length.toString());
    for(Map m in expenseList){
      print(m.toString());
      expenseTileList.add(listToTile(m));
    }
    //expenseTileList.add(listToTile(Map<String, dynamic>()));
    //expenseTileList.add(listToTile(Map<String, dynamic>()));
   // expenseTileList.add(listToTile(Map<String, dynamic>()));
    //expenseTileList.add(listToTile(Map<String, dynamic>()));
    //await Future.delayed(Duration(seconds: 2));
  }

  Container listToTile(Map<String, dynamic> map){
    Container container = Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      padding: EdgeInsets.all(10),
      child: InkWell(
        onTap: (){
          print("Tapped");
        },
        child: Column(
          children: [
            Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: Text(map['date'].toString(), style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Container(
                child: Row(
                  children: [
                    Container(
                        child: Expanded(
                          child: Text(map['title'], overflow: TextOverflow.ellipsis, softWrap: false,),
                        )
                    ),

                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async{
                          print("Pressed Delete");
                          await showDialog(context: context, builder: (BuildContext buildContext){
                            return DeleteConfirmDialog(expenseTitle: map['title'].toString());
                          }).then((value) async{
                            if(value){
                              print("Deleting...");

                              await database.delete('expensemain', where: 'id = ?', whereArgs: [map['id']]);
                              await database.rawQuery("drzop table table" + map['id'].toString());

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
                      ),
                    )


                  ],
                )
            )
          ],
        )
      )
    );

    return container;
  }
}