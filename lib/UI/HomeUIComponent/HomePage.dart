import 'dart:convert';

import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/account_settings.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/pendingShifts.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
/* import 'package:onesignal_flutter/onesignal_flutter.dart'; */
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  final firstTime;
  HomePage([this.firstTime]);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var now = new DateTime.now();
  var formatter = new DateFormat('yMMMd');
  var formatterTime = new DateFormat('kk:mm:a');
  bool isStarted = false;
  bool _checkUser = false;
  bool _isVisible = true;

  var _subInfo;
  bool notificationIsSwitched;

  @override
  void initState() {
    super.initState();
    setNotificationStatus();              
    _getEmail();    
    getNotifications();       
    trackSegment();
    WidgetsBinding.instance.addPostFrameCallback((_){
      checkNotificationPermission();       
    });
    /* notificationOne();    */ 
  }

  /* notificationOne() async {
    bool pushNotificationAllowed = await OneSignal.shared.promptUserForPushNotificationPermission();
    print('push');
    print(pushNotificationAllowed);
  } */

  trackSegment() {
    Segment.track(
      eventName: 'View Home',
      properties: {
        'Source': 'Native apps'
      }
    );
  }

  Future<void> _notificationsDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Don’t miss out on Opportunity'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Container(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                children: <Widget>[
                  Padding(child: Icon(Icons.notifications_active, color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action), size: 30.0),padding: EdgeInsets.only(right: 10.0)),
                  Text('Get notified about your new \n opportunities and application status')
                ],
              )
                )
              ),                          
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () async {              
              var status = await Permission.notification.request();   
              print('statud');   
              print(status);
              if (status.isDenied) {
                turnOnOfNotifications(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );             
              } else {
                await openAppSettings();
                turnOnOfNotifications(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }              
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () async {
              var notificationStatus = await Permission.notification.request();   
              var locationStatus = await Permission.locationWhenInUse.request();
              print('statud');   
              print(locationStatus);
              print(notificationStatus);
              if (notificationStatus.isGranted) {
                turnOnOfNotifications(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );            
              } else {
                await openAppSettings();
                turnOnOfNotifications(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }          
                /* openAppSettings();    */                
            },
          ),
        ],
      );
    },
  );
}

  checkNotificationPermission() async {
    if (widget.firstTime == true) {
      _notificationsDialog();             
    } else {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var status = await Permission.notification.request();   
      if (sharedPreferences.getString('notificationSubscription') == 'true' && status.isGranted != true) {
        _notificationsDialogRemember();
      }
    }
  }
  Future<void> _notificationsDialogRemember() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('App notification permission is turned of'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Row(
                  children: <Widget>[
                    Padding(child: Icon(Icons.notifications_active, color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action), size: 30.0),padding: EdgeInsets.only(right: 10.0)),
                    Text('Turn the app \nnotification permission on')
                  ],
                )
                  )
                ),                          
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () async {              
                var status = await Permission.notification.request();   
                print('statud');   
                print(status);
                if (status.isDenied) {
                  turnOnOfNotifications(false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );             
                } else {
                  /* await openAppSettings(); */
                  await turnOnOfNotifications(false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }              
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                var status = await Permission.notification.request();   
                print('statud');   
                print(status);
                if (status.isGranted) {
                  turnOnOfNotifications(true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );            
                } else {
                  await openAppSettings();
                  turnOnOfNotifications(true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }          
                  /* openAppSettings();    */                
              },
            ),
          ],
        );
      },
    );
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

  /* checkNotificationStatus() async {        
    if (_subInfo.subscriptionStatus.subscribed) {
      setState(() {
        notificationIsSwitched = true;
      });
    } else {
      setState(() {
        notificationIsSwitched = false;
      });
    }
  } */

  String _brand_color_primary_action = "";

  SharedPreferences prefs;
  var _checkUserName;
  var _checkCoordinates = "";  
  String _checkUserEmail = "";
  String _checkUserProfile = "";
  bool subscriptionState;
  var _userNameFinal ;
  var _userNameSplit;

  String _checkUserId = "";
  String _checkUserType = "";  
  String _checkUserCode = "";  
  String _checkUserTypeCode = "";
  String tenant = Constants.tenant;
  String _totalCount="";

  Future<Null> _getEmail() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString("token") != null) {
//          print('woo');
        _checkUser = true;
      }
      _checkUserName = prefs.getString("name");
      _brand_color_primary_action = prefs.getString('brand_color_primary_action');
      print('color');
      print(_brand_color_primary_action);
      print(_checkUserName);
//      _checkUserName = "ALi Sheikh";
      _userNameFinal = _checkUserName.split(" ");
      print('nameeee');
      print(_userNameFinal[0]);
      _userNameSplit = _userNameFinal[0];
      _checkUserEmail = prefs.getString("email");
      _checkUserProfile = prefs.getString("profile_url");
    });
  }

  getNotifications() async {
    if (GlobalData().notificationsAmount != null) {
      _totalCount = GlobalData().notificationsAmount.toString();
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _checkUserId = sharedPreferences.getString("userID");
    print('user id');
    print(_checkUserId);
    List<Notiification> responseNotification = [];
    final String postsURL =
        "#/prod?user_id="+_checkUserId+"&api_key=value2&tenant="+tenant;
    var token = sharedPreferences.getString("token");
    Response res = await get(postsURL,
        );
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      var dataHolder = responseJson ;

      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          Notiification models = Notiification.fromJson(dataJob);
          /* if (models.content_type == 'new_notification' ||  models.content_type == 'notification'){                       
          } */
//          Notiification modelsNotification = Notiification.fromJson(dataJob);
//          responseNotification.add(modelsNotification);
        }
        HttpRequests().getUnreadNotificationsAmount().then((amount) {
          GlobalData().notificationsAmount = amount;
          setState(() {
            _totalCount = amount.toString();
          }); 
        });                  
      }
    }    
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
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
    final String postsURL = 'https://svk2a7wbej.execute-api.us-east-1.amazonaws.com/prod/?data={"coordinates":"$_checkCoordinates","coordinates_type":"Onesignal","user_code":"$_checkUserCode","user_type":"$_checkUserType","user_type_code":"$_checkUserTypeCode","name":"$_checkUserName","tenant_key":"$tenant","subscribed":$subscriptionState}&key_action=update_coordinates&tenant=$tenant&api_key=value2';        
        print(postsURL);
    var token = sharedPreferences.getString("token");
    Response res = await post(postsURL,
              headers: {'authorization': token}
        );
    if (res.statusCode == 200) {      
      var responseJson = jsonDecode(res.body);
      print('respuesta');
      print(responseJson);
      sharedPreferences.setString('notificationSubscription', subscriptionState.toString());      
      setState(() {                
      });
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
        if (sharedPreferences.getString('notificationSubscription') == 'false') {
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

  Color hexToColor(String code) {
    Color color = code != null ? new Color(int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000) : Colors.white;
    return color;
  }

  @override
  Widget build(BuildContext context) {
//    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    var _pageSize = MediaQuery.of(context).size.height;
    var _notifySize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: hexToColor('#f3f5f6'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:hexToColor('#f3f5f6'),
        actions: <Widget>[

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute<void>(
                        builder: (BuildContext context) => notification()));
                  },

//                  onTap: () {
//                    Navigator.of(context).push(PageRouteBuilder(
//                        pageBuilder: (_, __, ___) => new notification()));
//                  },
                  child: Stack(
                    alignment: AlignmentDirectional(-3.0, -3.0),
                    children: <Widget>[
                      Image.asset(
                        "assets/img/notifications-button-black.png",
                        height: 24.0,
                      ),
                      CircleAvatar(
                        radius: 8.6,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          _totalCount.toString(),
                          style: TextStyle(fontSize: 13.0, color: Colors.white),
                        ),
                      )
                    ],
                  ),

                ),
                padding: EdgeInsets.only(right: 15),
              ),
            ],
          ),
        ],
      ),
      drawer: MainMenu(),
      body: Column(
      children: <Widget>[
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(

                            child: Text("Nice to meet " , style: TextStyle(color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action), fontSize: 40, fontWeight: FontWeight.w300, fontFamily: 'Sans'),),
                            padding: EdgeInsets.only(left: 40,top: 0),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text("You, ${_userNameSplit}" , style: TextStyle(color:  hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action) , fontSize: 40, fontWeight: FontWeight.w300, fontFamily: 'Sans'),),
                            padding: EdgeInsets.only(left: 40,top: 0),
                          ),

                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
//                          InkWell(
//                            onTap: (){
//                              Navigator.of(context).push(CupertinoPageRoute<void>(
//                                  builder: (BuildContext context) => Job()));
//                            },
//                            child: Align(
//
//                              alignment: Alignment.center,
//                              child: Container(
//                                height: 40.0,
//                                width: 160,
//                                margin: EdgeInsets.only(left: 10),
//                                child: Text(
//                                  'View Upcoming Shifts',
//                                  style: TextStyle(
//                                      color: Colors.white,
//                                      letterSpacing: 0.2,
//                                      fontFamily: "Sans",
//                                      fontSize: 14.0,
//                                      fontWeight: FontWeight.w300),
//                                ),
//                                alignment: FractionalOffset.center,
//                                decoration: BoxDecoration(
//                                    boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
//                                    borderRadius: BorderRadius.circular(10.0),
//                                    gradient: LinearGradient(
//                                        colors: <Color>[Color(0xFF000000), Color(0xFF000000)])
//                                ),
//                              ),
//                            ),
//                          ),

                    Align(

                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.only(top:20,bottom: 20),
                        child: Image.asset('assets/img/imghome2.png' , fit: BoxFit.fitHeight, width: 180,height: MediaQuery.of(context).size.height/3.15,),

                      ),
                    )
                  ],
                ),
//                      Row(
//                        children: <Widget>[
//                          Align(
//                            alignment: Alignment.topLeft,
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              children: <Widget>[
//                                Container(
//
//                                  child: Text("Explore our new winter menu. " , style: TextStyle(color: Color.fromRGBO(88, 88, 88, 1) , fontSize: 15, fontWeight: FontWeight.w300, fontFamily: 'Sans'),),
//                                  padding: EdgeInsets.only(left: 40,top: 0, bottom: 15),
//                                ),
//
//                              ],
//                            ),
//                          )
//                        ],
//                      ),





                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: <Widget>[


                      Container(
                        margin:EdgeInsets.only(top: 20,),
                        padding: EdgeInsets.only(left: 20 , top: 5, bottom: 5),

                        decoration: new BoxDecoration (
                          color: Colors.white,
                          border: Border(

                            bottom: BorderSide( //                    <--- top side
                              color: hexToColor('#f4f5f6'),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).push(CupertinoPageRoute<void>(
                                builder: (BuildContext context) => Job()));
                          },
                          child: ListTile(

                            title: Text('View Schedule' , style: TextStyle(color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action), fontFamily: 'Sans')),
                            leading: Icon(Icons.camera  , color:  hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action)) ,
                            trailing: Icon(Icons.keyboard_arrow_right , color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action)),

                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(left: 20, top: 10,bottom: 10),
                        decoration: new BoxDecoration (

                          color: Colors.white,
//                        border: Border(
//
//                          bottom: BorderSide( //                    <--- top side
//                            color: hexToColor('#f4f5f6'),
//                            width: 1.0,
//                          ),
//                        ),
                        ),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).push(CupertinoPageRoute<void>(
                                builder: (BuildContext context) => AccountSettings()));
                          },
                          child: ListTile(
                            title: Text('Account settings' , style: TextStyle(color:  hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action), fontFamily: 'Sans')),
                            leading: Icon(Icons.assignment_ind , color:  hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action)) ,
                            trailing: Icon(Icons.keyboard_arrow_right   , color:  hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action)),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: (){
                          print('ja raha hai');
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height/4.2,
                          padding: EdgeInsets.only(left: 20, top: 0,bottom: 0),
                          decoration: new BoxDecoration (

                            color: hexToColor(global.brand_color_primary_action != null ? global.brand_color_primary_action : _brand_color_primary_action),
//                        border: Border(
//
//                          bottom: BorderSide( //                    <--- top side
//                            color: hexToColor('#f4f5f6'),
//                            width: 1.0,
//                          ),
//                        ),
                          ),
                          child: InkWell(
                            onTap: (){
                              Navigator.of(context).push(CupertinoPageRoute<void>(
                                  builder: (BuildContext context) => Menu()));
                            },
                            child: ListTile(
                              title: Container(
                                  padding: EdgeInsets.only(top:10),
                                  child: Text('Available Shifts' , style: TextStyle(color: Colors.white, fontFamily: 'Sans' , fontSize: 25,fontWeight: FontWeight.w300))),
//                              leading: Icon(Icons.assignment_ind , color: Colors.white) ,
                            subtitle: Text('FIND JOBS', style: TextStyle(color: Colors.white, fontFamily: 'Sans' , fontSize: 15,fontWeight: FontWeight.w300)),
                              trailing:  Icon(FontAwesomeIcons.chevronCircleRight, color: Colors.white,),
                            ),
                          ),
                        ),
                      ),








                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
      ),



    );
  }
}
