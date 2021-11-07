import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/globals.dart' as global;

class SignUpDone extends StatefulWidget {

  @override
  _SignUpDoneState createState() => _SignUpDoneState();
}

class _SignUpDoneState extends State<SignUpDone> {

  @override
  void initState() {    
    super.initState();    
    startFadeIn();    
  }  
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
  
  var _iconVisible = false;  
  var _textVisible = false;  
  var _buttonVisible = false;  

  startFadeIn() {
    Timer(Duration(milliseconds: 200), () {
      setState(() {        
        _iconVisible = true;
      });
    });
    Timer(Duration(milliseconds: 400), () {
      setState(() {
        _textVisible = true;
      });
    });
    Timer(Duration(milliseconds: 600), () {
      setState(() {
        _buttonVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE4F0),   
        body: Container(
          alignment: Alignment.center,                  
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[                      
              /* Lottie.asset(Constants.buttonLoadingAnimation), */
              Expanded(
                child: Container(                  
                  alignment: Alignment.center,
                  /* height: MediaQuery.of(context).size.height * 0.7, */
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: _iconVisible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: Icon(Icons.verified_user, size: 200.0, color: hexToColor(global.brand_color_primary_action),)
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _textVisible ? 1.0 : 0.0,
                        child: Text(
                          'Welcome, you are ready to get some jobs!',
                          textAlign: TextAlign.center,
                          style: TextStyle(                      
                            fontFamily: "Gotik",
                            fontWeight: FontWeight.w600,
                            color: Colors.black54, 
                            fontSize: 25.0  
                          )                       
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _buttonVisible ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Container(
                      height: 55.0,
                      width: 600.0,
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.2,
                            fontFamily: "Sans",
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800),
                      ),
                      alignment: FractionalOffset.center,
                      decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
                          borderRadius: BorderRadius.circular(30.0),
                          gradient: LinearGradient(
                              colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
                    ),
                  ),
                ),
              )
            ],
          )
        ), 
      ),
    );
  }
}