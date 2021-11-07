import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
/* import 'package:json_to_form/json_schema.dart'; */
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wolf_jobs/Library/json_to_form/json_to_form.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/account_settings.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/multiSelectChip.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/customForms.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class JobTypePreferences extends StatefulWidget {  
  final fromAccountSettings;
  JobTypePreferences([this.fromAccountSettings]);

  @override
  _JobTypePreferencesState createState() => _JobTypePreferencesState();
}

class _JobTypePreferencesState extends State<JobTypePreferences> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();    
    getJobTypes();
    pageLoading = true;     
    /* print(json.encode(json1[1]));    */
  }    

  bool choiceSelected = false;
  
  List jobTypes;
  getJobTypes() async {
    await HttpRequests().getJobTypes().then((jobs) {
      setState(() {
        jobTypes = jobs;        
      });
      for (var i = 0; jobTypes.length > i; i++) {
        if (jobTypes[i]['interested']) {
          activeJobTypes.add(jobTypes[i]['id']); 
          activeJobsIndex.add(i);
        }
        jobTypesNames.add(jobTypes[i]['name']);
      }
      print(activeJobTypes);
    });
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  getNotifications() async {        
    if (GlobalData().notificationsAmount != null) {
      _totalCount = GlobalData().notificationsAmount.toString();
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _checkUserId = sharedPreferences.getString("userID");
    final String postsURL =
        "#/prod?user_id=" +
            _checkUserId +
            "&api_key=value2&tenant=" +
            tenant;
    var token = sharedPreferences.getString("token");
    Response res = await get(postsURL,
        headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      var dataHolder = responseJson;

      if (dataHolder != null) {
        HttpRequests().getUnreadNotificationsAmount().then((amount) {
          GlobalData().notificationsAmount = amount;
          setState(() {
            _totalCount = amount.toString();
          });
        });
      }
    }

    setState(() {
//      modelsNotification = responseNotification;
//      if (models.length == 0) {
//        _isVisible = !_isVisible;
//      }
    });
  }

  Widget updateButton() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: !loadingButton ? Text(
          widget.fromAccountSettings != null ? 'Update' : 'Next',
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }

  String _totalCount = "";
  String _checkUserId = "";
  String tenant = Constants.tenant;
  bool pageLoading;
  List activeJobTypes = [];
  List<int> activeJobsIndex = [];
  List<String> jobTypesNames = [];
  bool loadingButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: /* const Color(0xFFDDE4F0) */Colors.white,
        appBar: AppBar(
          title: Text(
            'Job Type Preferences',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme:
              IconThemeData(color: hexToColor(global.brand_color_bg_light)),
          elevation: 0.0,
        ),        
        body: jobTypes != null ? Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child:Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[ 
              Container(                
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.6),
                child: Center(
                  child: SingleChildScrollView(

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.0),
                          padding: EdgeInsets.only(bottom: 30.0),
                          child: Text(
                            'Select the job types you are interested in',
                            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ),
                        jobTypesNames != null ?
                        Container(                    
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          alignment: Alignment.center,
                          child: MultiSelectChip(
                            activeJobsIndex,
                            jobTypesNames,
                            onSelectionChanged: (selectedList) {
                              print('selected list');
                              print(selectedList);      
                              activeJobTypes = [];              
                              for (var i = 0; selectedList.length > i; i++) {
                                print('activo');
                                print(activeJobTypes);    
                                print('job ids');
                                print(jobTypes[selectedList[i]]['id']);                      
                                activeJobTypes.add(jobTypes[selectedList[i]]['id']);
                                /* if (!activeJobTypes.contains(jobTypes[selectedList[i]]['id'])) {
                                  setState(() {
                                    activeJobTypes.add(jobTypes[selectedList[i]]['id']);
                                  });
                                } else {                               
                                  setState(() {
                                    activeJobTypes.removeWhere((item) => item == jobTypes[selectedList[i]]['id']);
                                  });
                                } */
                                print('activo post');
                                print(activeJobTypes);
                              }
                            },
                          ),
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
              ),              
               /* ListView.builder(
                 shrinkWrap: true,
                 itemCount: jobTypes.length,
                 itemBuilder: (context, index) {
                   return Container(
                     padding: EdgeInsets.symmetric(horizontal: 30.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                         Text(jobTypes[index]['name']),
                         Switch(
                           value: jobTypes[index]['interested'],
                           onChanged: (value) {
                             setState(() {
                               jobTypes[index]['interested'] = value;
                             });   
                             print('active');
                             print(activeJobTypes);                          
                             if (value == true && !activeJobTypes.contains(jobTypes[index]['id'])) {
                               setState(() {
                                 activeJobTypes.add(jobTypes[index]['id']);
                               });
                             } else if (value == false) {                               
                               setState(() {
                                 activeJobTypes.removeWhere((item) => item == jobTypes[index]['id']);
                               });
                             }
                             print(activeJobTypes);
                           },
                         ),
                       ],
                     ),
                   );
                 },
               ),   */        
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, left: 30.0, right: 30.0),
                    child: Divider(
                      color: Colors.black12,
                      height: 2.0,
                    ),
                  ),
                  InkWell(
                  splashColor: Colors.yellow,
                  onTap: () {
                    FocusScope.of(context)
                        .requestFocus(new FocusNode());                    
                    print(activeJobTypes.join(','));
                    if (widget.fromAccountSettings != null) {
                      if (activeJobTypes.length > 0) {
                        setState(() {
                          loadingButton = true;
                        });    
                        HttpRequests().setJobTypes(activeJobTypes.join(',').toString()).then((value) {
                          setState(() {
                            loadingButton = false;                        
                          }); 
                          showToast("Updated successfully!", duration: 4, gravity: Toast.BOTTOM);
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new AccountSettings()));
                        }); 
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new AccountSettings()));
                      }   
                    } else {
                      if (activeJobTypes.length > 0) {
                        setState(() {
                          loadingButton = true;
                        });    
                        HttpRequests().setJobTypes(activeJobTypes.join(',').toString()).then((value) {
                          setState(() {
                            loadingButton = false;                        
                          }); 
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new CustomForms()));
                        }); 
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new CustomForms()));
                      }    
                    }                   
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: /* !loadingButton ?  */updateButton()/*  : loader() */,
                  ))
                ],
              ),                            
            ],
          ),
        ) : Container(
          child: Center(
            child: CircularProgressIndicator(),
          )
        )
    );
  }

  Widget loader() {
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