import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class FilePickerDemo extends StatefulWidget {
  final hasResume;

  FilePickerDemo(this.hasResume);

  @override
  _FilePickerDemoState createState() => new _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
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

  @override
  void initState() {
    super.initState();    
    _controller.addListener(() => _extension = _controller.text);
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _filePicker() async {
    print('hi');
    File file = await FilePicker.getFile();
//    print(file);
//    if (!mounted) return;
//    setState(() {
////      _fileHolder =  file;
//    });

    if (file != null) {
      _isLoadingSecondary = true;
      try {
        if (_isLoadingSecondary == true) {
          showToast('File Uploading Please Wait',
              duration: 10, gravity: Toast.BOTTOM);
        }
        FormData formData =
            new FormData.fromMap({"file": MultipartFile.fromFile(_path)});
        var dio = Dio(BaseOptions(
          connectTimeout: 5000,
        ));
        dio.interceptors.add(LogInterceptor(responseBody: true));
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        Response response = await dio.post(
          "https://www.filestackapi.com/api/store/S3?key=AwqN8FPp7Soa3DU6jTSt2z",
          data: file.openRead(), // Post with Stream<List<int>>
//          data: _path,
          options: Options(
            headers: {
              HttpHeaders.userAgentHeader: "dio",
              'Accept': '*/*',
              HttpHeaders.contentTypeHeader: ContentType.text,
//              HttpHeaders.contentLengthHeader: img.lengthSync(),
            },
            contentType: 'application/octet-stream',
            responseType: ResponseType.plain,
          ),
        );
        if (response.statusCode == 200) {
          _isLoadingSecondary = false;
//          UI.showSnacBar(context, "File Uploaded Successfully");
//          print(response.data);
          var anyfilestackresponse = jsonDecode(response.data);

          setState(() {
            profileType = anyfilestackresponse['url'];
          });
          updateProfileWithResume();
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('profiletype', profileType);
        } else {
          showToast('File Upload Failed Please try agin',
              duration: 4, gravity: Toast.BOTTOM);
        }
      } catch (e) {
        print(e);
//        return false;
      }
    }
  }

  void updateProfileWithResume() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String auth_token = sharedPreferences.get('token');


    String tenant = Constants.tenant;


    String updateProfileURL =
        "https://www.ondemandstaffing.app/api/v1/create_or_update_jobseeker?tenant=" +
            tenant +
            "&profileType=JobSeeker&name=&profiletype=" +
            profileType;

    Map<String, String> headers = {
      'AUTHORIZATION': auth_token,
    };

//
    Map<String, dynamic> dataDic = {
      'tenant': tenant,
      'profiletype': profileType,
    };
    print('data');
    print(auth_token);

    try {
      http.Response response = await http.post(updateProfileURL,
          headers: headers, body: jsonEncode(dataDic));
      var jsonResponse;
      if (response.statusCode == 200) {
        _isLoadingSecondary = false;
        jsonResponse = jsonDecode(response.body);
        showToast('File Uploaded', duration: 4, gravity: Toast.BOTTOM);
        print(jsonResponse);
      }
    } catch (err) {
      print("response error is: $err");
      setState(() {
        _isLoading = false;
        showToast(err, duration: 4, gravity: Toast.BOTTOM);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (){
          _filePicker();
        },
        child: Padding(
          padding:EdgeInsets.only(left: 30,right: 15,bottom: 0,top: 0),
          child: Container(
            margin: EdgeInsets.only(bottom: 0.0),
            height: 55.0,
//                        width: 600.0,
            child: _isLoadingSecondary ? Center(child: SizedBox(height: 25.0, width: 25.0, child: CircularProgressIndicator(valueColor : AlwaysStoppedAnimation(Colors.black), strokeWidth: 2.0,),),) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.file_upload , color: Colors.black,size: 20,)),
                SizedBox(width: 10,),
                Text(
                  widget.hasResume == 'true' ? 'Update Resume' : 'Upload Resume',
                  style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 0.2,
                      fontFamily: "Sans",
                      fontSize: 18.0,),
                ),

              ],
            ),
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
      ),
    );
  }
}
