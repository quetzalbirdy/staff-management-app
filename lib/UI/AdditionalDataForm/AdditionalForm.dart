import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/testForm.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/uploadFile.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/uploadFile_test.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/model/AdditionalData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;

class AdditionalForm extends StatefulWidget {
  @override
  _AdditionalFormState createState() => _AdditionalFormState();
}

class _AdditionalFormState extends State<AdditionalForm> {
  AnimationController animationController;

  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;

  SharedPreferences prefs;
  String _checkUserAuthImage;
  bool _isLoading = false;
  bool _isLoadingFreeText = false;
  bool _isLoadingSecondary = false;
  final translator = GoogleTranslator();

  final nameController = TextEditingController();

//  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  File _profilePic;
  String _selectedGender = "Select Gender";
  File _imageFile;
  File _anyFile;
  String profileType;
  String tenant = Constants.tenant;
  var FileStackImageUrl;

  String _gender;
  String _translation;
  String checkProfile;

  SharedPreferences sharedPrefs;
  TextEditingController _controller = new TextEditingController();

  List<String> docPaths;
  List<AdditionalData> models = [];
  bool _isVisible = true;
  PageController _pageController;
  List<String> _locations = ['A', 'B', 'C', 'D'];
  bool _isCheckHolder = true;
  final _titleFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('ops');
    print(_locations);
    getFormFields();
  }
//  @override
//  void dispose() {
//    _pageController.dispose();
//    super.dispose();
//  }

  List shiftIDs = [];
  String idList;

  String freeText;

  var listFreeText = {};
  var listDropdown = {};

//  insertIds() {
//    for (var i in widget.Joblistholder.shifts) shiftIDs.add(i.id);
//
//    getIds();
//  }

  getIds() {
    setState(() {
      idList = shiftIDs.join(',');
      print(idList);
//      print(idList);
    });
  }

  getFormFields() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    ;
    List<AdditionalData> response = [];
    List<AdditionalData> responseFile = [];
    List<AdditionalData> responseFinal = [];    
    final String postsURL =
        "https://www.ondemandstaffing.app/api/v1/jobseeker/get_custom_onboarding?tenant=" +
            tenant;
    print(postsURL);
    Response res = await get(postsURL,
        headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      print('data');
      print(responseJson);
      var dataHolder = responseJson;

      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          AdditionalData models = AdditionalData.fromJson(dataJob);
          print('models');
          response.add(models);
//            if (models.field_type != 'Checkbox' && models.field_type != 'File'){
//            print(models.options);
////            for (var modelHolder in models.options ){
////              _locations = modelHolder ;
////            }
//            response.add(models);
//            }
//          if (models.field_type == 'File'){
//            print(models.options);
////            for (var modelHolder in models.options ){
////              _locations = modelHolder ;
////            }
//            responseFile.add(models);
//          }
//
//          responseFinal.addAll(responseFile);
//          responseFinal.addAll(response);

        }
      }
    }
    models = sortList(response);
    setState(() {      
//      models = responseFinal;
      if (models.length == 0) {
        _isVisible = !_isVisible;
        startTime();
      }
    });
  }

  startTime() async {
    return new Timer(Duration(milliseconds: 3500), NavigatorPage);
  }

  void NavigatorPage() {
    /// if userhas never been login
    Navigator.of(context).pushReplacement(
        PageRouteBuilder(pageBuilder: (_, __, ___) => HomePage()));
  }

  List<AdditionalData> sortList(List<AdditionalData> orignalList) {
    List<AdditionalData> sortedList = [];    

    List<AdditionalData> pinnedModels = [];
    List<AdditionalData> unPinnedModels = [];

    for (int i = 0; i < orignalList.length; i++) {
      if (orignalList[i].field_type != 'Checkbox' &&
          orignalList[i].field_type == 'File') {
        pinnedModels.add(orignalList[i]);
      } else if (orignalList[i].field_type != 'File') {
        unPinnedModels.add(orignalList[i]);
      }
    }
    sortedList.addAll(unPinnedModels);
    sortedList.addAll(pinnedModels);

    return sortedList;
  }

  /* bool validateTextFields() {
    if (_translation == null) {
      showToast("Please select value!", gravity: Toast.BOTTOM);
      return false;
    }

    return true;
  } */

  bool validateFreeTextFields() {
//    if (nameController.text == null) {
//      showToast("Please Add Text!", gravity: Toast.BOTTOM);
//      return false;
//    }
//
//    return true;
  }

  Future<void> updateFreeText(String custom_requirement_id, value) async {    
    /* _formKey.currentState.save(); */
    /* String iniValue = _formData['value']; */    
    /* setState(() {
        _isLoadingFreeText = true;
      }); */
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String auth_token = sharedPreferences.get('token');

//      String profile_url = sharedPreferences.setString('profile_url');

      String tenant = Constants.tenant;

      String updateProfileURL =
          "https://www.ondemandstaffing.app/api/v1/jobseeker/get_custom_onboarding?tenant=" +
              tenant +
              "&custom_requirement_id=$custom_requirement_id&value=" +
              value;
      print(updateProfileURL);
      Map<String, String> headers = {
        'AUTHORIZATION': auth_token
//        "Content-Type": "application/x-www-form-urlencoded",
      };

      print('data');
      print(auth_token);
//      print(dataDic);

      try {
        http.Response response =
            await http.post(updateProfileURL, headers: headers);
        var jsonResponse;
        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body);
          print('response');
          print(jsonResponse);
          setState(() {                      
            showToast("Updated successfully!",
                duration: 4, gravity: Toast.BOTTOM);
          });
        } else {
          setState(() {
            _isLoadingFreeText = false;
            jsonResponse = json.decode(response.body);
            showToast('Update error', duration: 4, gravity: Toast.BOTTOM);
          });
        }
      } catch (err) {
        print("response error is: $err");
        setState(() {
          _isLoadingFreeText = false;
          showToast(err, duration: 4, gravity: Toast.BOTTOM);
        });
      }
  }

  Future<void> updateProfile(String custom_requirement_id, value) async {
    SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String auth_token = sharedPreferences.get('token');
      print('auth token');
      print(auth_token);

//      String profile_url = sharedPreferences.setString('profile_url');

      String tenant = Constants.tenant;
      print(tenant);

      String updateProfileURL =
          "https://www.ondemandstaffing.app/api/v1/jobseeker/get_custom_onboarding?tenant=" +
              tenant +
              "&custom_requirement_id=${custom_requirement_id}&value=" +
              value;
      print(updateProfileURL);
      Map<String, String> headers = {
        'AUTHORIZATION': auth_token
//        "Content-Type": "application/x-www-form-urlencoded",
      };

      print('data');
      print(auth_token);
//      print(dataDic);

      try {
        http.Response response =
            await http.post(updateProfileURL, headers: headers);
        var jsonResponse;
        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body);
          print('response');
          print(jsonResponse);
          setState(() {
            /* _isLoading = false;            
            _isLoadingFreeText = false; */
            showToast("Updated successfully!",
                duration: 4, gravity: Toast.BOTTOM);
          });
        } else {
          setState(() {
            /* _isLoading = false; */
            jsonResponse = json.decode(response.body);
            showToast('Update error', duration: 4, gravity: Toast.BOTTOM);
          });
        }
      } catch (err) {
        print("response error is: $err");
        setState(() {
          /* _isLoading = false; */
          showToast(err, duration: 4, gravity: Toast.BOTTOM);
        });
      }
  }

  final _formsPageViewController = PageController();
  final Map<String, dynamic> _formData = {
    'value': null,
//    'price': null,
//    'image': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  void _prev() {
    _formsPageViewController.previousPage(
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

  @override
  Widget build(BuildContext context) {
    /// Declare MediaQueryData
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    /// To Sett PhotoProfile,Name and Edit Profile

    Color hexToColor(String code) {
      Color color = code != null
          ? new Color(
              int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000)
          : Colors.white;
      return color;
    }

    var data = EasyLocalizationProvider.of(context).data;    
    return EasyLocalizationProvider(      
      data: data,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Additional Data',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
//            leading: new IconButton(
//                icon: new Icon(Icons.arrow_back_ios),
//                onPressed: () {
////                  Navigator.of(context).pop(true);
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(builder: (context) => HomePage()),
//                  );
//                }),

          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            // action button
          ],

          iconTheme:
              IconThemeData(color: hexToColor(global.brand_color_bg_light)),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: GestureDetector(            
            onTap: () {
              print('tap');
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }              
            },                       
            child: Listener(
              onPointerMove: (opm) {
                FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }    
              },
              child: SingleChildScrollView(          
              child: Container(               
                  color: Colors.white,
                  child: Column(                                                  
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0.0, left: 30.0, right: 30.0, bottom: 0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      Padding(                        
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height*.77,
                          child:  Visibility(                        
                            visible: _isVisible,
                            child: getAllFormField(),
                            replacement: Card(
                              child: new ListTile(
                                title: Center(
                                  child: new Text(
                                    'You are all set',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                            )),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0,),
                        child: Container(
                          /* decoration: BoxDecoration(border: Border.all(width: 2.0,)), */
                          color: Colors.transparent,        
                          margin: EdgeInsets.only(top: 0, bottom: 0),                                
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,                        
                            children: <Widget>[
                              /// Button Pay
                              InkWell(
                                onTap: () {   
                                                                
                                  if (_formKey.currentState.validate()) {
                                      setState(() {
                                        _isLoadingFreeText = true;
                                      });
                                      _formKey.currentState.save();   
                                      print('datos free');
                                      print(listFreeText);                                                                                                                             
                                      print('datos drop');
                                      print(listDropdown);  
                                      for (var entry in listDropdown.entries) {
                                        updateProfile(entry.key, entry.value);
                                        print(entry.key);
                                        print(entry.value);
                                      }
                                      for (var entry in listFreeText.entries) {
                                        updateFreeText(entry.key, entry.value);
                                        print(entry.key);
                                        print(entry.value);
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      ); 
                                      _isLoadingFreeText = false;  
                                    }                                                                                                                                                                                                                                             
                                },
                                child: Container(
                                  height: 59.0,
      //                        width: 200.0,
                                  margin: EdgeInsets.only(bottom: 0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.indigoAccent,
                                  ),

                                  child: Center(
                                    child: !_isLoadingFreeText ? Text(
                                      'Complete',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ) : Center(child: SizedBox(height: 20.0, width: 20.0, child: CircularProgressIndicator(valueColor : AlwaysStoppedAnimation(Colors.white), strokeWidth: 3.0)))
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAllFormField() {    
    if (models.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }        
    
    return Form(
      key:  _formKey,
      child: Container(                                                 
        child: ListView.builder(                              
          itemCount: models.length,   
          padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0, bottom: 15.0),       
          itemBuilder: (context, position) {                       
            if (models[position].field_type == 'Dropdown') {                  
              return Column(                  
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, bottom: 0, left: 30.0, right: 30.0),
                    /* child: Divider(
                      color: Colors.black12,
                      height: 2.0,
                    ), */
                  ),
                  /* Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10, left: 30.0, right: 30.0),
                    child: Container(
                      child: Text(
                        models[position].question.trim(),
                        style: TextStyle(fontSize: 14),
                      ),
                      alignment: Alignment.topLeft,
                    ),
                  ), */
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 0, left: 30.0, right: 30.0),
                  ),
                  Container(                    
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.0),                        
                        color: Colors.white,                        
                        boxShadow: [
                          BoxShadow(blurRadius: 10.0, color: Colors.black12)
                        ]),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
                      alignment: AlignmentDirectional.center,
                      height: 60.0,

                      padding: EdgeInsets.only(left: 0.0, right: 10.0, top: 0.0, bottom: 0.0),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          width: MediaQuery.of(context).size.width*0.75,                     
                          child: DropdownButtonFormField<String>(                            
                              icon: Icon(Icons.keyboard_arrow_down , size: 12, color: Colors.black,),                           
                              isDense: true,
                              isExpanded: true,
                              style: TextStyle(fontSize: 16, fontFamily: 'Sans'),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(0.0),
                                border: InputBorder.none,                                 
                                labelStyle: new TextStyle(                                      
                                    fontSize: 15,
                                    fontFamily: 'sans',
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w600),
                                labelText: models[position].question,
                              ),
                              items: models[position].options.map((String val) {
                                return new DropdownMenuItem<String>(                                
                                  value: val,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          val.toString(),
                                          style: TextStyle(
                                            color: Colors.black,  
                                            fontSize: 14.0                                            
                                          ),
                                        )
                                      ],
                                    )
                                    ),
                                );
                              }).toList(),
                              value: listDropdown[models[position].custom_requirement_id.toString()],
                              validator: (value) => value == null ||
                                      value == 'Please select a value'
                                  ? 'Select a value' 
                                  : null,
                              onChanged: (newVal) {
                                listDropdown[models[position].custom_requirement_id.toString()] = newVal;
                                /* _translation = newVal;  */                                                           

                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(
                                  () {},
                                );
                              },
                              onSaved: (String value) async {
                                listDropdown[models[position].custom_requirement_id.toString()] = value;                              

                              /*  print('models info');
                              print(models[position].custom_requirement_id.toString());
                              print(models.length); */                                                        
                                /* FocusScope.of(context).requestFocus(new FocusNode());
                                setState(() {
                                  _isLoading = true;
                                });
                                await updateProfile(
                                    models[position].custom_requirement_id.toString()); 
                                if (models[position] == (models.length-1)) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );  
                                }   */                                                                                   
                              }, 
                            ),
                        ),
                      ],
                    )
                    )
                  /* botonnnn */
                  /* InkWell(
                      splashColor: Colors.yellow,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        setState(() {
                          _isLoading = true;
                        });
                        updateProfile(
                            models[position].custom_requirement_id.toString());
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: !_isLoading ? updateButton() : Loader(),
                      )), */
                ],
              );
            }  else if (models[position].field_type == 'Freetext') {
              var controller = models[position].field_type;
    //                                 controller = TextEditingController() ;
              return Column(
                children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.only(
                         top: 0.0, bottom: 0,  left: 30.0, right: 30.0),
                     /* child: Divider(
                       color: Colors.black12,
                       height: 2.0,
                     ), */
                   ),
                  Container(                                                      
                    /* decoration: BoxDecoration(border: Border.all(width: 2.0, color: Colors.red)), */
                    padding: EdgeInsets.only(top: 10.0),                
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Container(                                                
                          height: 60.0,
                          alignment: AlignmentDirectional.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              color: Colors.white,
                              boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
                          padding:
                          EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
                          child: Theme(
                            data: ThemeData(
                              hintColor: Colors.transparent,
                            ),
                            child: TextFormField(     
                              initialValue: listFreeText[ models[position].custom_requirement_id.toString()] != null ? listFreeText[ models[position].custom_requirement_id.toString()] : null,                     
                              focusNode: _titleFocusNode,                                                            
        //                                              controller: nameController,
                              decoration: InputDecoration(                              
                                  errorStyle: TextStyle(
                                    fontSize: 0.0,
                                  ),
                                  /* border: InputBorder.none, */
                                  border: InputBorder.none, 
                                  labelText: models[position].question.trim(),
                                  labelStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Sans',
                                      letterSpacing: 0.3,
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w600)),

                              validator: (String value) {
                                // if (value.trim().length <= 0) {
                                if (value.isEmpty) {
                                  return 'Please Add Text!';
                                }
                              },                                  
                              onChanged: (String value) {   
                                listFreeText[ models[position].custom_requirement_id.toString()] = value;                                
                              },                       
                              onSaved: (String value) {   
                                listFreeText[ models[position].custom_requirement_id.toString()] = value;                                                        
                              /*  _formData['value'] = value;                            
                                await updateFreeText(
                                  models[position].custom_requirement_id.toString()
                                ); */
                                /* if (models[position] == (models.length-1)) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      );  
                                  }  */                           
                              },                            
                            ),
                          ),
                        ),
                      ),
                  )
                ],
              );
            } else if (models[position].field_type == 'File') {
              return Column(
                children: <Widget>[                  
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 30.0, right: 30.0, bottom:10),
                        /* child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ), */
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, left: 30.0, right: 30.0, bottom: 10),
                        child: Text(models[position].question.trim(),),
                      ),
                      AdditionalDataUploadForm(key: UniqueKey(),custom_requirement_id: models[position].custom_requirement_id.toString(),),
                    ],
                  )
                ],
              );
            } else {
              return Container(); /* Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, bottom: 0,  left: 30.0, right: 30.0),

                    ),

                    Text(''),



                  ],
                ); */

            } 
          }),
    ),
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Widget updateButton() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 30, bottom: 0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          'Save',
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
    );
  }

  Widget Loader() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }
}

class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      key: UniqueKey(),
      crossAxisAlignment: this.crossAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      mainAxisAlignment: this.mainAxisAlignment,
      verticalDirection: this.verticalDirection,
      children:
          new List.generate(this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}