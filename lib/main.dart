
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'expensemain.dart';
import 'newexpense.dart';
import 'deleteconfirmdialog.dart';
import 'expensedetail.dart';
import 'informationPage.dart';

Database database;
final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

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
  final String title = "My Expenses";
  @override
  Widget build(BuildContext buildContext){
    return MaterialApp(
      home: HomePage(title: title),
      title: title,
      routes: {
        'informationPage': (context) => new InformationPage()
      }
    );
  }

  @override
  void dispose(){
    database.close();
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
  double opacity = 0;

  Widget mainBody, addNew, appScreen, currentPage;
  bool loaded = false;
  bool refreshListCalled = false;
  ListBody listBody;
  @override
  void initState(){
    super.initState();
  }


  Future<void> refreshLoading() async{
    await Future.delayed(Duration(milliseconds: 900));
    setState(() {
      opacity = opacity == 1 ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    if(!loaded){
      appScreen = MainLoadingPage(opacity: this.opacity,);
      refreshLoading();
      if(!refreshListCalled) {
        refreshListCalled = true;
        refreshList().then((value){
          loaded = true;
        });
      }
    }else{
      mainBody = mainBodyAddContainer();
      addNew = Container();

      if(expenses.isNotEmpty){
        addNew = IconButton(
            icon: Icon(Icons.create_outlined),
            onPressed: () async {
              showDialog(context: context, builder: (BuildContext buildContext){
                return NewExpenseDialog(database: database,);
              }).then((value){
                if(value != null){
                  expenses.insert(0, value);
                  listKey.currentState.insertItem(0, duration: Duration(milliseconds: 500));
                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext buildContext) => new ExpenseDetail(expense: value, database: database,))).then((value) async{
                    if(value!=null){
                      await Future.delayed(Duration(milliseconds: 100));
                      expenses.removeAt(0);
                      //await Future.delayed(Duration(milliseconds: 300));
                      listKey.currentState.removeItem(0, (context, animation) => null, duration: Duration(milliseconds: 300));
                      if(expenses.isEmpty){
                        setState(() {
                          loaded = true;
                        });
                      }
                    }
                  });
                }else{
                  print("Not");
                }
              });
            }
        );
        mainBody = ListBody(expenses: expenses, parent: this);
      }

      appScreen = Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: (){
                Navigator.of(context).pushNamed('informationPage');
              },
            ),
            backgroundColor: Colors.black87,
            centerTitle: true,
            title: Container(
                child: Column(
                  children: [
                    Container(
                        //padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white
                          ),
                        )
                    ),
                  ],
                )
            ),
            actions: [
              //refresh
              addNew
            ],
          ),
          body: mainBody
      );
    }
    return appScreen;
  }

  Widget mainBodyAddContainer(){
    return Center(
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(10)),
            child: FlatButton(
                child: Text(
                    "+ Add Expense",
                    style: TextStyle(color: Colors.white)
                ),
                onPressed: () async {
                  showDialog(context: context, builder: (BuildContext buildContext){
                    return NewExpenseDialog(database: database,);
                  }).then((value){
                    if(value != null){
                      setState(() {
                        expenses.add(value);
                        loaded = true;
                      });
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext buildContext) => new ExpenseDetail(expense: value, database: database,))).then((value){
                        if(value != null) {
                          expenses.removeAt(0);
                          if(expenses.isEmpty){
                            setState(() {
                              loaded = true;
                            });
                          }
                        }

                      });
                    }else{
                    }
                  });
                }
            )
        )
    );
  }

  Future<void> refreshList() async {
    ExpenseMain.count = Sqflite.firstIntValue(await database.rawQuery("Select count(*) from expensemain"));
    expenseList.clear();
    expenseTileList.clear();
    expenseList.addAll(await database.rawQuery("Select * from expensemain order by id desc"));
    expenses.clear();
    ExpenseMain temp;
    for(Map m in expenseList){
      temp = ExpenseMain.fromMap(m);
      expenses.add(temp);
      //expenseTileList.add(listToTile(temp));
    }
   await Future.delayed(Duration(milliseconds: 1200));
  }
}

class MainLoadingPage extends StatefulWidget{
  final double opacity;
  MainLoadingPage({Key key, this.opacity}):super(key: key);
  MainLoadingPageState createState() => MainLoadingPageState();
}

class MainLoadingPageState extends State<MainLoadingPage> with SingleTickerProviderStateMixin{
  AnimationController animationController;
  @override
  void initState(){
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400)
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Animation");
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: widget.opacity,
              child: Text(
                "My Expenses",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30
                ),
              ),
            )
        )
    );
  }
}

class ListBody extends StatefulWidget{
  List<ExpenseMain> expenses;
  _myHomePageState parent;
  ListBody({Key key, this.expenses, this.parent}):super(key: key);
  ListBodyState createState() => ListBodyState();
}

class ListBodyState extends State<ListBody> with SingleTickerProviderStateMixin{
  AnimationController animationController;


  @override
  void initState(){
    super.initState();
    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300)
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      itemBuilder: (context, index, animationController){
        return getItem(context, index, animationController);
      },
      initialItemCount: widget.expenses.length,
    );
  }

  Container getItem(context, index, animationController){
    ExpenseMain expense = widget.expenses[index];
    AnimatedListRemovedItemBuilder builder = (context, animationController){
      return getItem(context, index, animationController);
    };
    Container container = Container(
        child: SlideTransition(
          child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.pinkAccent, width: 0.5))),
              padding: EdgeInsets.fromLTRB(9, 14, 5, 5),
              child: InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext buildContext) => new ExpenseDetail(expense: expense, database: database,)
                        )
                    ).then((value) async{
                      if(value!=null){
                        listKey.currentState.removeItem(index, builder, duration: Duration(milliseconds: 100));
                        if(index == widget.expenses.length-1) {
                          await Future.delayed(Duration(milliseconds: 300));
                        }
                        widget.expenses.removeAt(index);
                        if(widget.expenses.isEmpty){
                          widget.parent.setState((){});
                        }
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
                                            fontSize: 20,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                                      child: Text(expense.date, style: TextStyle(fontSize: 11, color: Colors.white70),),
                                    ),
                                  ]
                              )
                          )
                      ),
                      Container(
                        //decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () async{
                              showDialog(context: context, builder: (BuildContext buildContext){
                                return DeleteConfirmDialog(expenseTitle: expense.title);
                              }).then((value) async{
                                if(value){
                                  await database.delete('expensemain', where: 'id = ?', whereArgs: [expense.id]);
                                  await database.rawQuery("drop table table" + expense.id.toString());
                                  listKey.currentState.removeItem(index, builder, duration: Duration(milliseconds: 100));
                                  if(index == widget.expenses.length-1) {
                                    await Future.delayed(Duration(milliseconds: 300));
                                  }
                                  widget.expenses.removeAt(index);
                                  if(widget.expenses.isEmpty){
                                    widget.parent.setState(() {
                                      widget.parent.loaded = true;
                                    });
                                  }
                                }
                              });
                            },
                          )
                      ),
                    ],
                  )
              )
          ),
          position: Tween<Offset>(
              begin: const Offset(-1,0),
              end: Offset(0, 0)
          ).animate(animationController),
          textDirection: TextDirection.rtl,
        )
    );

    return container;
  }


}

