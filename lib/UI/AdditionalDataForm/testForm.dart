import 'dart:convert';
import 'dart:io';

import 'package:wolf_jobs/model/AdditionalData.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:validate/validate.dart';  //for validation
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;


class MyData {
  String name = '';
  String phone = '';
  String email = '';
  String age = '';
}



class StepperBody extends StatefulWidget {
  @override
  _StepperBodyState createState() => new _StepperBodyState();
}

class _StepperBodyState extends State<StepperBody> {
  final _formsPageViewController = PageController();
  List _forms;


  @override
  Widget build(BuildContext context) {
    for (int p=0; p<5; p++){
    _forms = [
      WillPopScope(
        onWillPop: () => Future.sync(this.onWillPop),
        child: Container(
            child:Column(
              children: <Widget>[
                Text('first'),
                InkWell(
                  onTap: (){
                    _nextFormStep();
                  },
                  child: Text('click me'),
                )
              ],
            )
        ),
      ),
//      WillPopScope(
//        onWillPop: () => Future.sync(this.onWillPop),
//        child:Container(child: Text('hi'),),
//      ),
    ];
    }



    return Container(
      height: 500,
      child: PageView.builder(
          controller: _formsPageViewController,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _forms[index];
          },
        ),
    );
  }

  void _nextFormStep() {
    _formsPageViewController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool onWillPop() {
    if (_formsPageViewController.page.round() ==
        _formsPageViewController.initialPage) return true;

    _formsPageViewController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );

    return false;
  }
}