
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

  Map<String, dynamic> copyCosts(Map<String, dynamic> obj){
    Map<String, dynamic> cost = Map<String, dynamic>();
    cost['title'] = obj['title'];
    cost['id'] = obj['id'];
    cost['ignore'] = obj['ignore'];
    cost['amount'] = obj['amount'];

    return cost;
  }

  void show(){
    print(id.toString() + " " + title + " " + tableName + " " + date);
    print("Costs:\n");
    for(Map m in costList){
      print(m.toString());
    }
  }
}