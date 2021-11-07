import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/UI/HomeUIComponent/webView.dart';

class ShowResume extends StatefulWidget {  
  @override
  _ShowResumeState createState() => new _ShowResumeState();
}

class _ShowResumeState extends State<ShowResume> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  String profileType;
  TextEditingController _controller = new TextEditingController();
  bool _isLoadingSecondary = false;
  bool _isLoading = false;

  /* @override
  void initState() {
    super.initState();    
    _controller.addListener(() => _extension = _controller.text);
  } */  

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        var resumeUrl = sharedPreferences.getString('resumeUrl');
        await launch(resumeUrl);        
      },
      child: Padding(
        padding:EdgeInsets.only(left: 0,right: 30,bottom: 0,top: 0),
        child: Container(
          margin: EdgeInsets.only(bottom: 0.0),
          height: 55.0,
          width: 55.0,
//                        width: 600.0,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.remove_red_eye , color: Colors.black,size: 20,)),
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),                        
            color: Colors.white,                        
            boxShadow: [
              BoxShadow(blurRadius: 10.0, color: Colors.black12)
            ]
          ),
//                          decoration: BoxDecoration(
//                              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
//                              borderRadius: BorderRadius.circular(10.0),
//                              gradient: LinearGradient(
//                                  colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),

        ),
      )
      /* Padding(
        padding:EdgeInsets.only(left: 30,right: 30,bottom: 0,top: 0),
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          height: 55.0,
//                        width: 600.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.file_upload , color: Colors.white,size: 20,)),
              SizedBox(width: 10,),
              Text(
                'Upload Resume',
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.2,
                    fontFamily: "Sans",
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800),
              ),

            ],
          ),
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
//                                color: Colors.white,
              gradient: LinearGradient(
                  colors: <Color>[Color(0xFF6E48AA), Color(0xFF6E48AA)]),
              boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
//                          decoration: BoxDecoration(
//                              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
//                              borderRadius: BorderRadius.circular(10.0),
//                              gradient: LinearGradient(
//                                  colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),

        ),
      ), */
    );
  }
}
