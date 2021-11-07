import 'dart:convert';
import 'dart:io';

import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/account_settings.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/signUpDone.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/pendingShifts.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/webView.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/customForms.dart';
import 'package:wolf_jobs/UI/chat/inbox.dart';
import 'package:wolf_jobs/UI/chat/messaging.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();        
    setNotificationStatus(); 
    _getEmail();           
    /* checkNotificationStatus(); */
  }

  var _checkUserName;
  bool notificationIsSwitched;  
  var _checkCoordinates = "";
  String _checkUserId = "";
  String _checkUserType = "";
  String _checkUserCode = "";
  String _checkUserTypeCode = "";
  bool subscriptionState;
  String _checkUserEmail;
  String _checkUserProfile;
  bool _checkUser = false;
  String tenant = Constants.tenant;

  Color hexToColor(String code) {
    Color color = code != null ? new Color(int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000) : Colors.white;
    return color;
  }

  Future<Null> _getEmail() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString("token") != null) {
        _checkUser = true;
      }
      _checkUserName = prefs.getString("name");
      _checkUserEmail = prefs.getString("email");
      _checkUserProfile = prefs.getString("profile_url");
//      _checkUserId = prefs.getString("userIDPre");
    });
  }

  setNotificationStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('notificationSubscription') != null) {
      if (sharedPreferences.getString('notificationSubscription') == 'true') {
        setState(() {
          notificationIsSwitched = true;
        });
      } else {
        setState(() {
          notificationIsSwitched = false;
        });
      }
    } else {
      setState(() {
        notificationIsSwitched = true;
      });
    }
  }

  turnOnOfNotifications(switchValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _checkUserId = sharedPreferences.getString("userID");
    _checkUserCode = sharedPreferences.getString("user_code");
    _checkUserType = sharedPreferences.getString("user_type");
    _checkUserTypeCode = sharedPreferences.getString("user_type_code");
    _checkUserName = sharedPreferences.getString("name");
    _checkCoordinates = sharedPreferences.getString("onesignalUserId");
    subscriptionState = switchValue;
    print('names');
    print('userId $_checkUserId');
    print('userCode $_checkUserCode');
    print('userType $_checkUserType');
    print('userTypeCode $_checkUserTypeCode');
    print('userName $_checkUserName');

    List<Notiification> responseNotification = [];
    final String postsURL =
        'https://svk2a7wbej.execute-api.us-east-1.amazonaws.com/prod/?data={"coordinates":"$_checkCoordinates","coordinates_type":"Onesignal","user_code":"$_checkUserCode","user_type":"$_checkUserType","user_type_code":"$_checkUserTypeCode","name":"$_checkUserName","tenant_key":"$tenant","subscribed":$subscriptionState}&key_action=update_coordinates&tenant=$tenant&api_key=value2';
    print(postsURL);
    var token = sharedPreferences.getString("token");
    Response res = await post(postsURL, headers: {'authorization': token});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      print('respuesta');
      print(responseJson);
      sharedPreferences.setString(
          'notificationSubscription', subscriptionState.toString());
      /* setState(() {}); */
      /* var dataHolder = responseJson ;

      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          Notiification models = Notiification.fromJson(dataJob);
          if (models.content_type == 'new_notification' ||  models.content_type == 'notification'){
            _totalCount = dataHolder.length.toString();
          }
//          Notiification modelsNotification = Notiification.fromJson(dataJob);
//          responseNotification.add(modelsNotification);


        }
      } */
    } else {
      showToast("There was a problem, please try again",
          duration: 4, gravity: Toast.CENTER);
      setState(() {
        if (sharedPreferences.getString('notificationSubscription') ==
            'false') {
          notificationIsSwitched = false;
        } else {
          notificationIsSwitched = true;
        }
      });
    }

    setState(() {
//      modelsNotification = responseNotification;
//      if (models.length == 0) {
//        _isVisible = !_isVisible;
//      }
    });
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: hexToColor(global
              .brand_color_bg_light), //This will change the drawer background to blue.
          //other styles
        ),
        child: Drawer(
          child: new ListView(
            children: <Widget>[
              Container(
                color: hexToColor(global.brand_color_bg_dark),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) =>
                                    profil(isFromSignUp: false)));
                          },
                          child: new UserAccountsDrawerHeader(
                            accountName: Text(
                                _checkUserName != null ? _checkUserName : '',
                                //                          global.name != null ? global.name : _checkUserName,
                                style: TextStyle(color: Colors.white)),
                            accountEmail: Text(
                                _checkUserEmail != null ? _checkUserEmail : '',
                                //                          global.email != null ? global.email : _checkUserEmail,
                                style: TextStyle(color: Colors.white)),
                            currentAccountPicture: GestureDetector(
                                child: CircleAvatar(
                              backgroundColor: Colors.white24,
                              backgroundImage: _checkUserProfile != null
                                  ? NetworkImage(_checkUserProfile)
                                  : AssetImage(
                                      'assets/img/dummyProfilePic.png'),
                            )),
                            decoration: new BoxDecoration(
                              color: hexToColor(global.brand_color_bg_dark),
                              /* border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.white70),
                        ), */
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  notificationIsSwitched == true
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  color: Colors.white,
                                  size: 35.0),
                              Switch(
                                value: notificationIsSwitched,
                                onChanged: (value) async {
                                  setState(() {
                                    notificationIsSwitched = value;
                                    print(notificationIsSwitched);
                                  });
                                  if (notificationIsSwitched == true) {
                                    var status =
                                        await Permission.notification.request();
                                    print('statud');
                                    print(status);
                                    if (status.isGranted) {
                                      turnOnOfNotifications(
                                          notificationIsSwitched);
                                    } else {
                                      await openAppSettings();
                                      turnOnOfNotifications(
                                          notificationIsSwitched);
                                    }
                                  } else {
                                    turnOnOfNotifications(
                                        notificationIsSwitched);
                                  }
                                },
                                activeTrackColor: Colors.white70,
                                activeColor: Colors.white,
                              ),
                            ],
                          ))
                    ]),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => HomePage()));
                },
                child: ListTile(
                  title: Text('Home',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  leading: Icon(Icons.home, color: Colors.white),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => Menu()));
                },
                child: ListTile(
                  title: Text(
                    'Available Shifts',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.event_note,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => PendingShifts()));
                },
                child: ListTile(
                  title: Text(
                    'Pending Shifts',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.hourglass_full,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => order()));
                },
                child: ListTile(
                  title: Text(
                    'Timesheets',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.schedule,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => Job()));
                },
                child: ListTile(
                  title: Text('Upcoming Shifts',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  leading: Icon(Icons.event_available, color: Colors.white),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) =>
                          /* profil(isFromSignUp: false))); */
                          ChatInbox()));
                },
                child: ListTile(
                  title: Text('Inbox',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  leading: Icon(Icons.markunread_mailbox, color: Colors.white),
                ),
              ), 
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) =>
                          /* profil(isFromSignUp: false))); */
                          AccountSettings()));
                },
                child: ListTile(
                  title: Text('Account settings',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  leading: Icon(Icons.person, color: Colors.white),
                ),
              ), 
              /* InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) =>
                          /* profil(isFromSignUp: false))); */
                          SignUpDone()));
                },
                child: ListTile(
                  title: Text('done',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  leading: Icon(Icons.person, color: Colors.white),
                ),
              ),  */                                                      
              Divider(
                thickness: 1,
                color: Colors.white70,
              ),
              InkWell(
                onTap: () async {                  
                  final SharedPreferences prefs = await SharedPreferences.getInstance();                  
                  final documentDirectory = (await getApplicationDocumentsDirectory()).path;
                  final directory = Directory(documentDirectory + '/' + Constants.tenant);
                  /* erase permanent variables */ 
                  prefs.clear();                  
                  /* erase cache */                                    
                  directory.deleteSync(recursive: true);                    
                  Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => LoginScreen()));                
//                      print('logout');
                },
                child: ListTile(
                  title: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
