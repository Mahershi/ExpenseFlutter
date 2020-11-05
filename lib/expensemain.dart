import 'package:flutter/cupertino.dart';

class ExpenseMain{
  static int count;
  int id = 0;
  String title;
  String tablename;

  ExpenseMain(this.title, this.tablename);

  ExpenseMain.fromMap(Map<String, dynamic> map){
    this.id = map['id'];
    this.title = map['title'];
    this.tablename = map['tablename'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = Map<String, dynamic>();
    if(id!=0)
      map['id'] = id;
    map['title'] = title;
    map['tablename'] = tablename;

    return map;
  }


  void show(){
    print(id.toString() + " " + title + " " + tablename);
  }
}