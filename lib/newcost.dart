import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewCost extends StatelessWidget{
  var _formKey = GlobalKey<FormState>();
  TextEditingController costNameController = TextEditingController();
  TextEditingController costAmountController = TextEditingController();
  Map<String, dynamic> cost = Map<String, dynamic>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Cost"),
      actions: [
        FlatButton(
          child: Text("Add"),
          onPressed: (){
            print("Add cost button");
            if(_formKey.currentState.validate()){
              print("Saving");
              cost['title'] = costNameController.text;
              cost['amount'] = costAmountController.text;
              cost['ignore'] = 0;
              print("New Cost: " + cost.toString());
              Navigator.of(context).pop(cost);
            }
          },
        ),
        FlatButton(
          child: Text("Discard"),
          onPressed: (){
            print("Discar Cost BUtton");
            Navigator.of(context).pop();
          },
        )
      ],
      content: Builder(builder: (BuildContext buildContext){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: TextFormField(
                        controller: costNameController,
                        decoration: InputDecoration(
                          hintText: "Cost Title",
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]+")),
                        ],
                        validator: (value){
                          if(value.isEmpty)
                            return "Enter title";
                          return null;
                        },
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        controller: costAmountController,
                        decoration: InputDecoration(
                          hintText: "Amount",
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value){
                          if(value.isEmpty)
                            return "Enter Amount";
                          return null;
                        },
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        );
      },),
    );
  }

}