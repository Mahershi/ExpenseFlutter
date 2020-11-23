import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Container(
            child: Column(
              children: [
                Container(
                  //padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      "About",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white
                      ),
                    )
                ),
              ],
            )
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Icon(Icons.person, size: 50,),
                    padding: EdgeInsets.all(10),
                  ),
                  Container(
                    child: Text(
                      "Created By:",
                      style: TextStyle(
                        fontSize: 14
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Mahershi Bhavsar",
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                          child: Icon(Icons.email_outlined)
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "mahershi1999@gmail.com"
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
        )
      ),
    );
  }

}