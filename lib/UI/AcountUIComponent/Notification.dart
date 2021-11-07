import 'dart:convert';

import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/pendingShifts.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/webView.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolf_jobs/globals.dart' as global;

class notification extends StatefulWidget {
  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<notification> {
  String tenant = Constants.tenant;
  String _checkUserId;

  List<Notiification> models = [];
  @override
  void initState() {
    super.initState();
    setNotificationStatus();
    /* getNotifications(); */
    checkLastApiCall();
    trackSegment();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  bool _isVisible = true;
  bool notificationIsSwitched;
  var _checkUserName;
  var _checkCoordinates = "";
  /* String _checkUserId = ""; */
  String _checkUserType = "";
  String _checkUserCode = "";
  String _checkUserTypeCode = "";
  bool subscriptionState;
  String _brand_color_primary_action = "";

  trackSegment() {
    Segment.track(
      eventName: 'View Notifications',
      properties: {
        'Source': 'Native apps'
      }
    );
  }

  getColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _brand_color_primary_action = prefs.getString('brand_color_primary_action');
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
      setState(() {});
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
    });
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  checkLastApiCall() async {
    var lastCallFile = await JsonStorage('lastNotificationsCall').readFile();
    DateTime now = DateTime.now();
    /* print(now.difference(DateTime.parse('2020-06-02 00:15:50.049789')).inMinutes); */
    if (lastCallFile == 'no file') {
      checkStorage();
      print(now);
      await JsonStorage('lastNotificationsCall').writeFile(now.toString());
    } else {
      if (now.difference(DateTime.parse(lastCallFile)).inMinutes > 4) {
        await JsonStorage('lastNotificationsCall').writeFile(now.toString());
        checkStorage();       
      } else {
        checkStorage(true);                
      }
    }
  }

  checkStorage([apiCall]) async {
    var notificationStorage = await JsonStorage('notifications').readFile();
    List<Notiification> response = [];
    List<Notiification> filterResponse = [];
    if (notificationStorage == 'no file') {      
      HttpRequests().getNotifications().then((notifications) {   
        HttpRequests().setReadNotifications().then((status) {
          if (status == 'updated') {
            GlobalData().notificationsAmount = 0;
          }
        });
        
        setState(() {
          models = List.from(notifications.reversed);
          if (models.length == 0) {
            _isVisible = false;
          }
        });
      });
    } else {
      var dataHolder = json.decode(notificationStorage);
      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          Notiification models = Notiification.fromJson(dataJob);
          if (models.content_type == 'new_notification' ||
              models.content_type == 'notification') {
            response.add(models);
          }
        }
        setState(() {
          models = List.from(response.reversed);
          if (models.length == 0) {
            _isVisible = false;
          }
        });
        if (apiCall == null) {
          HttpRequests().getNotifications().then((notifications) {
            HttpRequests().setReadNotifications().then((status) {
              if (status == 'updated') {
                GlobalData().notificationsAmount = 0;
              }
            });
            setState(() {
              models = List.from(notifications.reversed);              
              if (models.length == 0) {
                _isVisible = false;
              }
            });
          });
        }
      } else {
        return null;
      }
    }
  }  

  void _showErrorSnackBar() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Oops... the URL couldn\'t be opened!'),
      ),
    );
  }

  Widget getAllNotification() {
    if (models.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }
    /*  setState(() {
      models = List.from(models.reversed);
    }); */
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: models.length,
        reverse: false,
        padding: const EdgeInsets.all(5.0),
        itemBuilder: (context, position) {
          return Container(
            /* height: 72.0, */
            child: Column(              
              children: <Widget>[
//                Divider(height: 1.0),
                InkWell(
                  onTap: () async {
                    showModalBottomSheet(
                        context: context,
                        builder: (builder) {
                          return Theme(
                            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                            child: SingleChildScrollView(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.only(
                                      topLeft: Radius
                                          .circular(
                                          20.0),
                                      topRight: Radius
                                          .circular(
                                          20.0))),
                                /* color: Colors.black26, */
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Container(
  //                                  height: MediaQuery.of(context).size.height*.35,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0))),

                                    child: new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(top: 20.0)),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            'Content',
                                            style: TextStyle(
                                                fontFamily: "Gotik",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.0,
                                                color: Colors.black,
                                                letterSpacing: 0.3,
                                                wordSpacing: 0.5),
                                          ),
                                        ),
                                        models[position].subject != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0,
                                                    left: 20.0,
                                                    right: 20.0,
                                                    bottom: 20.0),
                                                child: Text(
                                                    models[position].content,
                                                    style: _detailText),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0,
                                                    left: 20.0,
                                                    right: 20.0,
                                                    bottom: 20.0),
                                                child: Text('Subject Not Found',
                                                    style: _detailText),
                                              ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            'Body',
                                            style: TextStyle(
                                                fontFamily: "Gotik",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.0,
                                                color: Colors.black,
                                                letterSpacing: 0.3,
                                                wordSpacing: 0.5),
                                          ),
                                        ),
                                        models[position].body != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0,
                                                    left: 20.0,
                                                    bottom: 10),
                                                child: Text(
                                                  models[position].body,
                                                  style: _detailText,
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0,
                                                    left: 20.0,
                                                    bottom: 10),
                                                child: Text(
                                                  'Body Not Found',
                                                  style: _detailText,
                                                ),
                                              ),
                                        /* models[position].actionurl_btn ==
                                                'Request to work'
                                            ? Padding(                                            
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    bottom: 10,
                                                    top: 30,
                                                    right: 30),
                                                child: Container(
                                                  alignment:
                                                      FractionalOffset.center,
                                                  height: 55,
  //                                                padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black38,
                                                            blurRadius: 15.0)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                      gradient: LinearGradient(
                                                          colors: <Color>[
                                                            Color(0xFF121940),
                                                            Color(0xFF6E48AA)
                                                          ])),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (await canLaunch(
                                                          models[position]
                                                              .action_url)) {
                                                        await launch(
                                                            models[position]
                                                                .action_url);
                                                      } else {
                                                        throw 'Could not launch ${models[position].action_url}';
                                                      }
                                                    },
                                                    child: Text(
                                                      'Request to work',
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15.0,
                                                          color: Colors.white,
                                                          letterSpacing: 0.3,
                                                          wordSpacing: 0.5),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Text(''), */
                                            (models[position].subject != 'New Message') ? Padding(
                                              padding: EdgeInsets.only(left: 30, bottom: 10, top: 30, right: 30),
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 20.0),
                                                alignment: FractionalOffset.center,
                                                height: 55,   
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black38,
                                                      blurRadius: 15.0)
                                                  ],
                                                  borderRadius: BorderRadius.circular(30.0),
                                                  gradient: LinearGradient(
                                                      colors: <Color>[
                                                        Color(0xFF121940),
                                                        Color(0xFF6E48AA)
                                                      ])),                                           
                                                child: InkWell(                                                                                                    
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    /* Navigator.of(context).push(CupertinoPageRoute<void>(
                                                      builder: (BuildContext context) => order())); */
                                                    if (models[position].notification_master_category != null || models[position].notification_sub_category != null) {
                                                      if (models[position].notification_master_category == 'shift') {
                                                        if (models[position].notification_sub_category == 'new_shift') {
                                                          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => Menu()));
                                                        } else if (models[position].notification_sub_category == 'check_in' || models[position].notification_sub_category == 'shift_reconfirm' || models[position].notification_sub_category == 'shift_assigned' || models[position].notification_sub_category == 'shift_update') {
                                                          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => Job()));
                                                        } else if (models[position].notification_sub_category == 'shift_cancelled') {
                                                          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => PendingShifts()));
                                                        }
                                                      } else if (models[position].notification_master_category == 'campaign') {
                                                        if (models[position].notification_sub_category == 'campaign_update') {
                                                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => AppWebView(models[position].action_url)));
                                                        } else if (models[position].notification_sub_category == 'new_campaign') {
                                                           Navigator.of(context).push(CupertinoPageRoute(builder: (_) => Menu()));
                                                        }
                                                      }
                                                    } else {
                                                      Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => AppWebView(models[position].action_url)));
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      /* Padding(padding: EdgeInsets.only(right: 5.0), child: Icon(Icons.event_note, color: Colors.white),), */
                                                      Text(models[position].actionurl_btn, style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: "Gotik",fontWeight: FontWeight.w600, letterSpacing: 0.3, wordSpacing: 0.5))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ) : Container(height: 0.0,),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: ListTile(
                    title: Text(
                      '${models[position].subject}',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        width: 440.0,
                        child: Text(
                          '${models[position].body}',
                          style: new TextStyle(
                              fontSize: 13.0,
                              fontStyle: FontStyle.italic,
                              color: Colors.black38),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50.0,
                          width: 50.0,
                          child: CachedNetworkImage(
                            imageUrl: global.logo,
                          ),
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.all(Radius.circular(60.0)),
//                            image: DecorationImage(image: CachedNetworkImage(imageUrl: global.logo,),fit: BoxFit.cover)
//                        ),
                        )
                      ],
                    ),
                  ),
                ),
//                Divider(height: 5.0),
              ],
            ),
          );
        }), 
        onRefresh: () async {            
          await HttpRequests().getNotifications().then((notifications) {      
            HttpRequests().setReadNotifications().then((status) {
              if (status == 'updated') {
                GlobalData().notificationsAmount = 0;
              }
            });
            setState(() {
              models = List.from(notifications.reversed);
              if (models.length == 0) {
                _isVisible = !_isVisible;
              }
            });               
          });  
        },
        key: _refreshIndicatorKey,
    );
  }

  static var _subHeaderCustomStyle = TextStyle(
      color: Colors.black/* 54 */,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Notifications',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.0,
                  color: Colors.black54,
                  fontFamily: "Gotik"),
            ),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                      notificationIsSwitched
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: hexToColor(global.brand_color_bg_dark),
                      size: 30.0),
                  Switch(
                    value: notificationIsSwitched,
                    onChanged: (value) async {
                      setState(() {
                        notificationIsSwitched = value;
                        print(notificationIsSwitched);
                      });
                      if (notificationIsSwitched == true) {
                        var status = await Permission.notification.request();
                        print('statud');
                        print(status);
                        if (status.isGranted) {
                          turnOnOfNotifications(notificationIsSwitched);
                        } else {
                          await openAppSettings();
                          turnOnOfNotifications(notificationIsSwitched);
                        }
                      } else {
                        turnOnOfNotifications(notificationIsSwitched);
                      }
                    },
                    activeTrackColor: Colors.grey,
                    activeColor: Colors.white,
                  )
                ],
              )
            ],
            iconTheme: IconThemeData(
              color: const Color(0xFF6991C7),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: <Widget>[
              Visibility(
                  visible: _isVisible,
                  child: getAllNotification(),
                  replacement: EmptyScreen()),
            ],
          )),
    );
  }
}

class noItemNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: 500.0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(top: mediaQueryData.padding.top + 100.0)),
            Image.asset(
              "assets/img/noNotification.png",
              height: 200.0,
            ),
            Padding(padding: EdgeInsets.only(bottom: 30.0)),
            Text(
              'Not Have Notification',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.5,
                  color: Colors.black54,
                  fontFamily: "Gotik"),
            ),
          ],
        ),
      ),
    );
  }
}
