import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ButtonProvider extends ChangeNotifier{
  ButtonProvider(
  {
    this.check = 0,
    this.name = "",
    this.score = 0,
  }
  );
  int check;
  String name;
  int score;

  Widget circleWidget(double width){
    if(check % 2 == 1) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              //blurRadius: 1.0,
              //spreadRadius: 1.0,
              //offset: Offset(10, 10))
            ),
          ],
          border: Border.all(color: Colors.black, width: 1),
          //borderRadius: BorderRadius.circular(12)),
        ),
      );
    }else{
      return Container(
        color: Colors.transparent,
      );
    }
  }
}