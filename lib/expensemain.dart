
import 'package:flutter/material.dart';

class ExpenseMain{
  static int count;
  int id = 0;
  String title;
  String tableName;
  String date;
  List<Map<String, dynamic>> costList = [];

  ExpenseMain(this.title, this.tableName, this.date);

  ExpenseMain.fromMap(Map<String, dynamic> map){
    this.id = map['id'];
    this.title = map['title'];
    this.tableName = map['tablename'];
    this.date = map['date'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = Map<String, dynamic>();
    if(id!=0)
      map['id'] = id;
    map['title'] = title;
    map['tablename'] = tableName;
    map['date'] = date;

    return map;
  }



  void show(){
    print(id.toString() + " " + title + " " + tableName + " " + date);
  }
}