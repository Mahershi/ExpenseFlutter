import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String capitalize(String input) => input[0].toUpperCase() + input.substring(1);

class NewCost extends StatelessWidget{
  Map<String, dynamic> cost;
  NewCost({Key key, this.cost}):super(key: key);
  bool newCost = false;

  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if(cost == null){
      cost = Map<String, dynamic>();
      cost['title'] = '';
      cost['amount'] = 0;
      cost['ignore'] = 0;
      newCost = true;
    }
    TextEditingController costNameController = TextEditingController(text: cost['title']);
    TextEditingController costAmountController = TextEditingController(text: cost['amount'].toString());

    FocusNode _focusNodeAmount = FocusNode();
    _focusNodeAmount.addListener(() {
      if(_focusNodeAmount.hasFocus){
        costAmountController.clear();
      }
    });

    FocusNode _focusNodeTitle = FocusNode();
    _focusNodeTitle.addListener(() {
      if(_focusNodeTitle.hasFocus)
        costNameController.clear();
    });
    return AlertDialog(
      title: Text("New Cost"),
      actions: [
        FlatButton(
          child: Text("Save"),
          onPressed: (){
            print("Add cost button");
            if(_formKey.currentState.validate()){
              print("Saving");
              cost['title'] = capitalize(costNameController.text);
              cost['amount'] = int.parse(costAmountController.text.toString());
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
                        focusNode: _focusNodeTitle,
                        controller: costNameController,
                        decoration: InputDecoration(
                          hintText: "Cost Title",
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pinkAccent
                            )
                          )
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
                        focusNode: _focusNodeAmount,
                        controller: costAmountController,
                        decoration: InputDecoration(
                          hintText: "Amount",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.pinkAccent
                                )
                            )
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