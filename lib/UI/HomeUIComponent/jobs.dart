import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
/* import 'package:geolocator/geolocator.dart'; */
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Map.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/ReportedTimesheet.dart';
import 'package:wolf_jobs/model/ShiftListHolder.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:wolf_jobs/widget/UI.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:http/http.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
/* import 'package:permission_handler/permission_handler.dart'; */
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/Api/jobs.dart';
import 'package:wolf_jobs/Library/carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/UI/HomeUIComponent/Profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:add_2_calendar/add_2_calendar.dart';

class Job extends StatefulWidget {
  final HttpService httpService = HttpService();

  @override
  _JobState createState() => _JobState();
}

/// Component all widget in home
class _JobState extends State<Job> with TickerProviderStateMixin {
  /// Declare class GridItem from HomeGridItemReoomended.dart in folder ListItem
//  GridItem gridItem;
  var now = new DateTime.now();
  var formatter = new DateFormat('d\nEE');
  var formatterDay = new DateFormat('d');
  var formatterMonth = new DateFormat('MMM');
  var formatterBasic = new DateFormat('yyyyMMdd');
  var formatterDayWeek = new DateFormat('EE');
  var formatterTime = new DateFormat('kk:mm:a');
  bool isStarted = false;
  bool _checkUser = false;
  bool _isVisible = true;
  bool isConfirm = true;

  List<bool> selectedDay = List.filled(30, false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLastApiCall();
    _getEmail();
    getNotifications();
    setNotificationStatus();
    trackSegment();
    /* checkNotificationStatus(); */
  }

  addDayToNow(number) {
    var nowDay = new DateTime(now.year, now.month, now.day + number);      
    return nowDay;
  }

  var _checkUserName;
  var _checkCoordinates = "";
  String _checkUserId = "";
  String _checkUserType = "";
  String _checkUserCode = "";
  String _checkUserTypeCode = "";
  bool subscriptionState;
  var shiftsByDate;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  List daysWithShifts = List();

  trackSegment() {
    Segment.track(
        eventName: 'View Upcoming jobs', properties: {'Source': 'Native apps'});
  }
  /* formatterBasic.format(DateTime.parse(obj.start)) */
  groupShiftsByDate(shifts) {   
   /*  for (var shift in shifts) {      
      shift.start = formatterBasic.format(DateTime.parse(shift.start)).toString();   
      print('start');
      print(shift.start);   
    } */
    List daysShifts = List();     
    var groupedShifts = groupBy(shifts, (obj) => formatterBasic.format(DateTime.parse(obj.start)).toString()).map(
      (k, v) => MapEntry(k, v.map((item) { /* item.remove('start') ;*/ return item;}).toList())
    );               
    for (var day in groupedShifts.keys.toList()) {      
      daysShifts.add(formatterBasic.format(DateTime.parse(day)));
    }    
    setState(() {           
      shiftsByDate = groupedShifts;        
      daysWithShifts = daysShifts;  
      print(daysWithShifts);        
    });  
  }

  checkLastApiCall() async {
    var lastCallFile = await JsonStorage('lastUpcomingShiftsCall').readFile();
    print('last file');
    print(lastCallFile);
    DateTime now = DateTime.now();
    /* print(now.difference(DateTime.parse('2020-06-02 00:15:50.049789')).inMinutes); */
    if (lastCallFile == 'no file') {
      checkStorage();
      print(now);
      await JsonStorage('lastUpcomingShiftsCall').writeFile(now.toString());
    } else {
      if (now.difference(DateTime.parse(lastCallFile)).inMinutes > 4) {
        await JsonStorage('lastUpcomingShiftsCall').writeFile(now.toString());
        checkStorage();       
      } else {
        checkStorage(true);                
      }
    }
  }

  checkStorage([apiCall]) async {
    var upcomingShiftsStorage = await JsonStorage('upcomingShifts').readFile();
    List<ShiftListHolder> response = [];
    if (upcomingShiftsStorage == 'no file') {
      HttpRequests().getUpcomingShifts().then((shifts) {
        setState(() {
          models = shifts;        
          groupShiftsByDate(models);  
          gridViewWidget();
          if (models.length == 0) {
            _isVisible = false;
          }
        });
      });
    } else {
      Map<String, dynamic> dataHolder =
          json.decode(upcomingShiftsStorage)['data']['shifts'];
                  
      if (dataHolder.isNotEmpty) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder.values.toList()[j];
          var dataSort = dataHolder.values.toList();
          dataSort.sort((a, b) {
            var adate = a['start']; //before -> var adate = a.expiry;
            var bdate = b['start']; //before -> var bdate = b.expiry;
            return adate.compareTo(
                bdate); //to get the order other way just switch `adate & bdate`
          });
          print('sort');
          print(dataSort);
          ShiftListHolder models = ShiftListHolder.fromJson(dataSort[j]);
          var data = dataHolder.values.toList()[j];
          print('tender');
          print(models.tender.availability_freshness);

          response.add(models);
          var shiftsHolder = data['campaign'];

          Campaign modelsShift = Campaign.fromJson(shiftsHolder);
          responseShift.add(modelsShift);

          if (data.containsKey('reported_timesheet')) {
            var reportTimesheet = data['reported_timesheet'];
            ReportedTimesheet modelsTimeshift =
                ReportedTimesheet.fromJson(reportTimesheet);
            responseTimesheet.add(modelsTimeshift);
          }
        }
        setState(() {
          models = response;   
          if (models.length == 0) {
            _isVisible = false;
          }       
          groupShiftsByDate(models);
          gridViewWidget();
        });
        if (apiCall == null) {
          HttpRequests().getUpcomingShifts().then((shifts) {
            setState(() {
              models = shifts;
              groupShiftsByDate(models);  
              gridViewWidget();          
              if (models.length == 0) {
                _isVisible = false;
              }
            });
          });
        }
      } else {        
        print('prueba');
        HttpRequests().getUpcomingShifts().then((shifts) {
          setState(() {
            models = shifts;
            groupShiftsByDate(models);  
            gridViewWidget();          
            if (models.length == 0) {
              _isVisible = false;
            }
          });
        });
      }
    }
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
//      modelsNotification = responseNotification;
//      if (models.length == 0) {
//        _isVisible = !_isVisible;
//      }
    });
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  var _subInfo;
  bool notificationIsSwitched;

  /* checkNotificationStatus() async {
    _subInfo = await OneSignal.shared.getPermissionSubscriptionState();
    print(_subInfo.subscriptionStatus.subscribed);
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

  SharedPreferences prefs;
  JsonStorage storage;
  /* String _checkUserName; */
  String _checkUserEmail;
  String _checkUserProfile;
  /* String _checkUserId = ""; */
  String tenant = Constants.tenant;
  String _totalCount = "";

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

  List<ShiftListHolder> models = [];
  List<Campaign> responseShift = [];
  List<ReportedTimesheet> responseTimesheet = [];

  /* getPosts() async {
    final String postsURL =
        "http://ondemandstaffing.app/api/v1/shifts/view_all_upcoming_assigned_jobs/?tenant=" + tenant;
    List<ShiftListHolder> response = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    Response res = await get(postsURL,
        headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      print(responseJson);
      Map<String, dynamic> dataHolder = responseJson['data']['shifts'];

      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder.values.toList()[j];
          var dataSort = dataHolder.values.toList();
          dataSort.sort((a, b) {
            var adate = a['start']; //before -> var adate = a.expiry;
            var bdate = b['start']; //before -> var bdate = b.expiry;
            return adate.compareTo(
                bdate); //to get the order other way just switch `adate & bdate`
          });

          ShiftListHolder models = ShiftListHolder.fromJson(dataSort[j]);
          var data = dataHolder.values.toList()[j];

          response.add(models);
          var shiftsHolder = data['campaign'];

          Campaign modelsShift = Campaign.fromJson(shiftsHolder);
          responseShift.add(modelsShift);

          if (data.containsKey('reported_timesheet')) {
            var reportTimesheet = data['reported_timesheet'];
            ReportedTimesheet modelsTimeshift =
                ReportedTimesheet.fromJson(reportTimesheet);
            responseTimesheet.add(modelsTimeshift);
          }
        }
      }
    }

    setState(() {
      models = response;
      if (models.length == 0) {
        _isVisible = !_isVisible;
      }
    });
  } */

  final String postsURLShifts =
      "http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/";

  Future shiftPosts(int id, String message, now) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print('location data');
    print(_locationData);
    
    /* Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best); */
    var token = sharedPreferences.getString("token");    
    Map<String, dynamic> data;
    if (_locationData.latitude != null){
      data = {
        'message': message,
        'shifts': id,
        'tenant': tenant,
        'timestamp': now.toString(),
        'latitude': _locationData.latitude.toString(),
        'longitude': _locationData.longitude.toString(),
      };
    } else {
      data = {
        'message': message,
        'shifts': id,
        'tenant': tenant,
        'timestamp': now.toString(),        
      };
    }
    var jsonResponse;
    Response res = await post(
      postsURLShifts,
      headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      print(data);
      var responseJson = jsonDecode(res.body);
      print(responseJson['message']);

      showToast(responseJson['message'], duration: 4, gravity: Toast.BOTTOM);
      setState(() {
        print('ok good');
        /* ************ */
        checkStorage();
        gridViewWidget();
      });
      return responseJson;
    } else {
      var responseJson = jsonDecode(res.body);
      showToast(responseJson["message"], duration: 4, gravity: Toast.BOTTOM);
    }
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

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
  

  void _bottomSheet() {}
  static var _subHeaderCustomStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);
  static var _dateFilterNumber = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

  var _dateFilter = null;

  Widget gridViewWidget() {
    if (models.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }

    return RefreshIndicator(
      child: ListView.builder(            
        shrinkWrap: true,  
        itemCount: shiftsByDate.length,            
        itemBuilder: (context, position) {
          return _dateFilter == null ? StickyHeaderBuilder(            
            key: UniqueKey(),
            builder: (context, stuckAmount) {              
              return Container(
                margin: EdgeInsets.only(left: 10.0, top: 0.0, bottom: 5.0),
                color: Colors.black54,
                alignment: Alignment.center,
                height: 70.0,
                width: 70.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      formatterMonth.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                      style: TextStyle(color: Colors.white, fontSize: 15.0, fontFamily: "Gotik",),                 
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            formatterDayWeek.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                            style: TextStyle(color: Colors.white, fontSize: 15.0,  fontFamily: "Gotik"),                  
                            textAlign: TextAlign.center,
                          ),
                        ), 
                        Text(
                          formatterDay.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                          style: TextStyle(color: Colors.white, fontSize: 15.0, fontFamily: "Gotik",),                 
                          textAlign: TextAlign.center,
                        ),                        
                      ],
                    ) 
                  ],
                )                
              );
            },
            content: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0),
              itemCount: shiftsByDate.values.toList()[position].length,
              itemBuilder: (context, index) {
                return Padding(
                  key: UniqueKey(),
                  padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                  child: Material(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        margin: EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            //                          border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0)),
                            //                          borderRadius: BorderRadius.only(Rad),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFDDE4F0).withOpacity(1.0),
                                blurRadius: 10.0,
                                spreadRadius: 10.0,
                                //           offset: Offset(4.0, 10.0)
                              )
                            ]),
                        child: Column(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context).size.width *
                                              0.58,
                                          //                                       width: 300,
                                          child: Text(
                                            shiftsByDate.values.toList()[position][index].job_type,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(
                                                letterSpacing: 0.0,
                                                color: Colors.blueAccent,
                                                fontFamily: "Sans",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 22.0),
                                          ),
                                        ),
                                        Text(
                                          shiftsByDate.values.toList()[position][index].client_name,
                                          style: TextStyle(
                                            fontFamily: "Sans",
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.0,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          width: 55.0,
                                          padding: EdgeInsets.only(right: 20),
                                          height: 45.0,
                                          decoration: new BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: new DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: new NetworkImage(
                                                      shiftsByDate.values.toList()[position][index]
                                                          .banner_image)))),
                                    ),
                                  ],
                                ),
                                /* Date and Time */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    //                                     Text(i.start),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0.0, top: 10.0, bottom: 10.0),
                                      child: Row(
                                        //                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                        //                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[                                           
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
                                                //                          border: Border.all(color: Colors.blueAccent),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5.0),
                                                    bottomRight:
                                                        Radius.circular(5.0),
                                                    topLeft: Radius.circular(5.0),
                                                    topRight: Radius.circular(5.0)),
                                                //                          borderRadius: BorderRadius.only(Rad),
                                              ),
                                              padding:
                                                  EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              height: 30,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        5, 0, 5, 0),
                                                    margin: EdgeInsets.fromLTRB(
                                                        2, 0, 3, 0),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                          //                                              right: BorderSide(width: 1.0, color: Colors.black12),
                                                          //                                              left: BorderSide(width: 1.0, color: Colors.black12),
                                                          ),
                                                    ),
                                                    child: Text(
                                                        formatterTime.format(
                                                            DateTime.parse(
                                                                shiftsByDate.values.toList()[position][index]
                                                                    .start)),
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            fontSize: 17,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700)),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                    //
                                                    child: Text('-',
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            fontSize: 17,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700)),
                                                  ),
                                                  Text(
                                                      formatterTime.format(
                                                          DateTime.parse(
                                                              shiftsByDate.values.toList()[position][index]
                                                                  .end)),
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 17,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ],
                                              ),
                                            ),
                                            flex: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                /* Direction */
                                FlatButton(
                                  padding:
                                      EdgeInsets.only(left: 0.0, top: 0.0),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute<void>(
                                            builder: (BuildContext
                                                    context) =>
                                                MapPage(shiftListHolder: shiftsByDate.values.toList()[position][index],)));
                                  },
                                  child: Container(
                                    child: Row(
                                      //                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.blueAccent,
                                          size: 24.0,
                                        ),
                                        SizedBox(
                                          height: 28.0,
                                          child: new Center(
                                            child: new Container(
                                              margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                              width: 1.0,
                                              height: 28.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText(
                                            shiftsByDate.values.toList()[position][index]
                                                .address,
                                            maxLines: 2,
                                            minFontSize: 13.0,
                                            maxFontSize: 15.0,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,                                                              
                                                fontFamily:
                                                    "Gotik",
                                                color: Colors
                                                    .black54,
                                                letterSpacing: 0,
                                                fontSize: 15.0,
                                                wordSpacing: 0),
                                            textAlign:
                                                TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                    /* flex: 3, */
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 7.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[                                
                                      shiftsByDate.values.toList()[position][index].contact_name != null && shiftsByDate.values.toList()[position][index].contact_name.isNotEmpty ?
                                      Expanded(                                  
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.supervised_user_circle,
                                              color: Colors.blueAccent,
                                              size: 24.0,
                                            ),
                                            SizedBox(
                                              height: 28.0,
                                              child: new Center(
                                                child: new Container(
                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                  width: 1.0,
                                                  height: 28.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 1),
                                                    child: Text(
                                                      "Contact Name:",
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                          letterSpacing: 0.0,
                                                          wordSpacing: 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width * .30,
                                                    padding: EdgeInsets.only(left: 1),
                                                    child: Text(

                                                      shiftsByDate.values.toList()[position][index].contact_name !=
                                                              null
                                                          ? shiftsByDate.values.toList()[position][index]
                                                              .contact_name
                                                          : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(

                                                          fontFamily: "Gotik",
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.black54,
                                                          letterSpacing: 0.1,
                                                          fontSize: 15.0,
                                                          wordSpacing: 0.2),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        flex: 1,
                                      ):
                                      Text(''),
                                      shiftsByDate.values.toList()[position][index].contact_number != null  && shiftsByDate.values.toList()[position][index].contact_number.isNotEmpty
                                      ?
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.contact_phone,
                                              color: Colors.blueAccent,
                                              size: 24.0,
                                            ),
                                            SizedBox(
                                              height: 28.0,
                                              child: new Center(
                                                child: new Container(
                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                  width: 1.0,
                                                  height: 28.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            FlatButton(
                                              padding: EdgeInsets.all(0.0),
                                              onPressed: () async {
                                                UrlLauncher.launch('tel:+${shiftsByDate.values.toList()[position][index].contact_number.toString()}');
                                              },  
                                                                                      
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.30,
                                                        padding: EdgeInsets.only(left: 1),
                                                        child: Text(
                                                          "Contact Number:",
                                                          style: TextStyle(
                                                              fontFamily: "Gotik",
                                                              color: Colors.black54,
                                                              letterSpacing: 0.0,
                                                              fontSize: 12,
                                                              wordSpacing: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 1),
                                                        child: Text(
                                                          shiftsByDate.values.toList()[position][index].contact_number !=
                                                                  null
                                                              ? shiftsByDate.values.toList()[position][index]
                                                                  .contact_number
                                                              : '',
                                                          style: TextStyle(
                                                              fontFamily: "Gotik",
                                                              fontWeight: FontWeight.w600,                                                    
                                                              color: Colors.black54,
                                                              letterSpacing: 0.1,
                                                              fontSize: 15,
                                                              wordSpacing: 0.2),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ),
                                          ],
                                        ),
                                        flex: 1,
                                      ):
                                      Text('') 
                                    ],
                                  ),
                                ),                                 
                                Padding(
                                  padding: EdgeInsets.all(0.0),                                  
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(                                        
                                      border: Border(
                                        top: BorderSide(
                                            width: 1.0,
                                            color: Colors.blueAccent),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            final Event shift = Event(
                                              title: shiftsByDate.values.toList()[position][index].job_type,
                                              description: 
                                              (shiftsByDate.values.toList()[position][index].campaign.notes != null && shiftsByDate.values.toList()[position][index].post_instruction != null) ?
                                              'Notes: ${shiftsByDate.values.toList()[position][index].campaign.notes}. Instructions: ${shiftsByDate.values.toList()[position][index].post_instruction}':
                                              shiftsByDate.values.toList()[position][index].campaign.notes != null ?
                                              'Notes: ${shiftsByDate.values.toList()[position][index].campaign.notes}.' :
                                              shiftsByDate.values.toList()[position][index].post_instruction != null ?
                                              'Instructions: ${shiftsByDate.values.toList()[position][index].post_instruction}' :
                                              'Working as ${shiftsByDate.values.toList()[position][index].job_type}',                                              
                                              location: shiftsByDate.values.toList()[position][index].address,
                                              startDate: DateTime.parse(shiftsByDate.values.toList()[position][index].start),
                                              endDate: DateTime.parse(shiftsByDate.values.toList()[position][index].end),
                                            );     
                                            Add2Calendar.addEvent2Cal(shift);                                     
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(Icons.event, color: Colors.blueAccent,),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5.0),
                                                child: Text(
                                                  'Add shift to calendar',
                                                  style: TextStyle(
                                                    fontFamily: 'Gotik',
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              ),                                            
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (builder) {
                                                return Container(                                      
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
                                                  child: new ListView(                                                
                                                    children: <Widget>[
                                                      /* PAY RATE */
                                                      shiftsByDate.values.toList()[position][index].campaign.pay_rate != null && shiftsByDate.values.toList()[position][index].campaign.pay_rate.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 20.0, left: 20.0),
                                                        child: Text(
                                                            'Pay Rate',
                                                            style:
                                                            _subHeaderCustomStyle,
                                                          ),
                                                      ) : Container(height: 0.0,),
                                                      shiftsByDate.values.toList()[position][index].campaign.pay_rate != null && shiftsByDate.values.toList()[position][index].campaign.pay_rate.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[                                                        
                                                            Icon(
                                                              Icons.monetization_on,
                                                              color: Colors.blueAccent,
                                                              size: 24.0,
                                                            ),
                                                            SizedBox(
                                                              height: 28.0,
                                                              child: new Center(
                                                                child: new Container(
                                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                  width: 1.0,
                                                                  height: 28.0,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.only(top: 0.0,left: 0.0,right: 0.0,bottom: 0.0),
                                                                child: AutoSizeText(
                                                                    '\$${shiftsByDate.values.toList()[position][index].campaign.pay_rate}/hr',
                                                                    style: TextStyle(
                                                                      fontFamily: "Gotik",
                                                                      fontSize: 20.0,
                                                                      color: Colors.black54,
                                                                      letterSpacing: 0.3,
                                                                      wordSpacing: 0.5
                                                                    )
                                                                  ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ) : Container(height: 0.0,),
                                                      /* INSTRUCTION */
                                                      shiftsByDate.values.toList()[position][index].post_instruction != null && shiftsByDate.values.toList()[position][index].post_instruction.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 20.0, left: 20.0),
                                                        child: Text(
                                                            'Instruction',
                                                            style:
                                                            _subHeaderCustomStyle,
                                                          ),
                                                      ) : Container(height: 0.0,),
                                                      shiftsByDate.values.toList()[position][index].post_instruction != null && shiftsByDate.values.toList()[position][index].post_instruction.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[                                                        
                                                            Icon(
                                                              Icons.supervised_user_circle,
                                                              color: Colors.blueAccent,
                                                              size: 24.0,
                                                            ),
                                                            SizedBox(
                                                              height: 28.0,
                                                              child: new Center(
                                                                child: new Container(
                                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                  width: 1.0,
                                                                  height: 28.0,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.only(top: 0.0,left: 0.0,right: 0.0,bottom: 0.0),
                                                                child: AutoSizeText(
                                                                    shiftsByDate.values.toList()[position][index]
                                                                        .post_instruction,
                                                                    style: _detailText),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ) : Container(height: 0.0,),  
                                                      /* NOTES */  
                                                      shiftsByDate.values.toList()[position][index].campaign.notes != null && shiftsByDate.values.toList()[position][index].campaign.notes.isNotEmpty ?                                                       
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            left: 20.0, top: 20.0),
                                                        child: Text(
                                                          'Notes',
                                                          style: _subHeaderCustomStyle,
                                                        ),  
                                                      ) : Container(height: 0.0,),                                                                                                                                              
                                                      shiftsByDate.values.toList()[position][index].campaign.notes != null && shiftsByDate.values.toList()[position][index].campaign.notes.isNotEmpty ?                                                     
                                                      Container(
                                                        width: MediaQuery.of(context).size.width * 0.9,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0, bottom: 20.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[  
                                                              Icon(
                                                                Icons.speaker_notes,
                                                                color: Colors.blueAccent,
                                                                size: 24.0,
                                                              ),
                                                              SizedBox(
                                                                height: 28.0,
                                                                child: new Center(
                                                                  child: new Container(
                                                                    margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                    width: 1.0,
                                                                    height: 28.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),                                                                                                        
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 0.0,
                                                                      left: 0.0),
                                                                  child: AutoSizeText(
                                                                    shiftsByDate.values.toList()[position][index].campaign.notes,
                                                                    style: _detailText,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ) : Container(height: 0.0,),                                                  
                                                    ],
                                                  ),
                                                );
                                              });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                'More Info',
                                                style: TextStyle(
                                                  fontFamily: 'Gotik',
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down, color: Colors.blueAccent,)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ),                        
                                shiftsByDate.values.toList()[position][index].reported_timesheet != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          //                                     Text(i.start),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                left: 0.0,
                                                right: 0.0,
                                                top: 15.0,
                                                bottom: 4),
                                            margin: EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.black12),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  //                                        width:MediaQuery.of(context).size.width*0.25,
                                                  child: Text('Checked in :',
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                                  margin: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                                  child: Text(
                                                      formatterTime.format(DateTime
                                                          .parse(shiftsByDate.values.toList()[position][index]
                                                              .reported_timesheet
                                                              .timein)),
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          shiftsByDate.values.toList()[position][index]
                                                      .reported_timesheet
                                                      .timeout !=
                                                  null
                                              ? Container(
                                                  padding: const EdgeInsets.only(
                                                      left: 0.0,
                                                      right: 0.0,
                                                      top: 15.0,
                                                      bottom: 15),
                                                  margin: EdgeInsets.only(top: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.black12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        //                                        width:MediaQuery.of(context).size.width*0.25,
                                                        child: Text('Checked out :',
                                                            style: TextStyle(
                                                                fontFamily: "Gotik",
                                                                fontSize: 15,
                                                                color: Colors.black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 0, 5, 0),
                                                        margin: EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                        child: Text(
                                                            formatterTime.format(
                                                                DateTime.parse(models[
                                                                        position]
                                                                    .reported_timesheet
                                                                    .timeout)),
                                                            style: TextStyle(
                                                                fontFamily: "Gotik",
                                                                fontSize: 15,
                                                                color: Colors.black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(child: Text('')),
                                        ],
                                      )
                                    : Container(
                                        child: Text(''),
                                      ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    //                                     Text(i.start),
                                    Container(
                                      //                                decoration: Border(top: ),
                                      margin: EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              width: 1.0, color: Colors.black12),
                                        ),
                                      ),
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0.0, top: 5.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          shiftsByDate.values.toList()[position][index].reported_timesheet ==
                                                  null
                                              ?

                                              //                                    formatter.format(DateTime.parse(shiftsByDate.values.toList()[position][index].start)) == DateTime.now() ?
                                              Container(
                                                  child: DateTime.parse(
                                                                  shiftsByDate.values.toList()[position][index]
                                                                      .start)
                                                              .difference(
                                                                  DateTime.now())
                                                              .inHours <=
                                                          28
                                                      ? InkWell(
                                                          onTap: () {
                                                            //                                          shiftPosts(shiftsByDate.values.toList()[position][index].id , 'check-in' , now);
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                  context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    'Are you sure you want to check in?',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17.0),
                                                                  ),
                                                                  //                          content: Text(successInformation['message']),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      child: Text(
                                                                          'No'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(
                                                                                context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    FlatButton(
                                                                      child: Text(
                                                                          'Yes'),
                                                                      onPressed:
                                                                          () {
                                                                        shiftPosts(
                                                                            shiftsByDate.values.toList()[position][index]
                                                                                .id,
                                                                            'check-in',
                                                                            now);
                                                                        setState(
                                                                            () {
                                                                          /* ********* */
                                                                          checkStorage();
                                                                          gridViewWidget();
                                                                        });

                                                                        //                                                      print('page loaded again');
                                                                        Navigator.of(
                                                                                context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(0.0),
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                      top: 10),
                                                              height: 40.0,
                                                              width:
                                                                  shiftsByDate.values.toList()[position][index]
                                                                          .isCheckIn
                                                                      ? 90.0
                                                                      : 190,
                                                              child: Text(
                                                                'Check-in',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.2,
                                                                    fontFamily:
                                                                        "Sans",
                                                                    fontSize: 14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              alignment:
                                                                  FractionalOffset
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      blurRadius:
                                                                          15.0)
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: hexToColor(global
                                                                    .brand_color_primary_action),
                                                                //                                                gradient: LinearGradient(
                                                                //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : shiftsByDate.values.toList()[position][index]
                                                                  .reported_timesheet !=
                                                              null
                                                          ? InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                        'Are you sure you want to check out?',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17.0),
                                                                      ),
                                                                      //                          content: Text(successInformation['message']),
                                                                      actions: <
                                                                          Widget>[
                                                                        FlatButton(
                                                                          child: Text(
                                                                              'No'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                        FlatButton(
                                                                          child: Text(
                                                                              'Yes'),
                                                                          onPressed: () {
                                                                            print('hi');
                                                                            shiftPosts(shiftsByDate.values.toList()[position][index].id, 'check-out', now);
                                                                            setState(() {                                                                              
                                                                              checkStorage();
                                                                              gridViewWidget();
                                                                            });
                                                                            print('page loaded again');
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        )
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        0.0),
                                                                child: shiftsByDate.values.toList()[position][index]
                                                                            .reported_timesheet
                                                                            .timeout ==
                                                                        null
                                                                    ? Container(
                                                                        margin: EdgeInsets
                                                                            .only(
                                                                                top:
                                                                                    10),
                                                                        height:
                                                                            40.0,
                                                                        width:
                                                                            120.0,
                                                                        child: Text(
                                                                          'Check out',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              letterSpacing:
                                                                                  0.2,
                                                                              fontFamily:
                                                                                  "Sans",
                                                                              fontSize:
                                                                                  14.0,
                                                                              fontWeight:
                                                                                  FontWeight.w600),
                                                                        ),
                                                                        alignment:
                                                                            FractionalOffset
                                                                                .center,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color:
                                                                                    Colors.black38,
                                                                                blurRadius: 15.0)
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  10.0),
                                                                          color: hexToColor(
                                                                              global
                                                                                  .brand_color_primary_action),
                                                                          //                                                gradient: LinearGradient(
                                                                          //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                                        ),
                                                                      )
                                                                    : Text(''),
                                                              ),
                                                            )
                                                          :
                                                          InkWell(
                                                              onTap: () {
                                                                if (!(shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0))) {
                                                                  shiftPosts(
                                                                        shiftsByDate.values.toList()[position][index]
                                                                            .id,
                                                                        'confirm',
                                                                        now)
                                                                    .then(
                                                                        (response) {});
                                                                }                                                                
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        0.0),
                                                                child: Container(
                                                                  
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top: 10),
                                                                  height: 40.0,
                                                                  width: 90.0,
                                                                  child: Text(
                                                                    (shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0)) ?
                                                                    'Confirmed' : 'Confirm',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.2,
                                                                        fontFamily:
                                                                            "Sans",
                                                                        fontSize:
                                                                            14.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600),
                                                                  ),
                                                                  alignment:
                                                                      FractionalOffset
                                                                          .center, 
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .black38,
                                                                          blurRadius:
                                                                              15.0)
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10.0),
                                                                    color: hexToColor(
                                                                        global
                                                                            .brand_color_primary_action/* '#195e83' */).withOpacity((shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0)) ? 0.5 : 1.0),
                                                                    //                                               gradient: LinearGradient(
                                                                    //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                )
                                              : shiftsByDate.values.toList()[position][index]
                                                          .reported_timesheet !=
                                                      null
                                                  ? Container(
                                                      child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                'Are you sure you want to check out?',
                                                                style: TextStyle(
                                                                    fontSize: 17.0),
                                                              ),
                                                              //                          content: Text(successInformation['message']),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text('No'),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                FlatButton(
                                                                  child:
                                                                      Text('Yes'),
                                                                  onPressed: () {
                                                                    print('hi');
                                                                    shiftPosts(
                                                                        shiftsByDate.values.toList()[position][index]
                                                                            .id,
                                                                        'check-out',
                                                                        now);
                                                                    setState(() {
                                                                      /* ****** */
                                                                      checkStorage();
                                                                      gridViewWidget();
                                                                    });

                                                                    print(
                                                                        'page loaded again');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();                                                                        
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        child: shiftsByDate.values.toList()[position][index]
                                                                    .reported_timesheet
                                                                    .timeout ==
                                                                null
                                                            ? Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                        top: 10),
                                                                height: 40.0,
                                                                width: 120.0,
                                                                child: Text(
                                                                  'Check out',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          0.2,
                                                                      fontFamily:
                                                                          "Sans",
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                alignment:
                                                                    FractionalOffset
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .black38,
                                                                        blurRadius:
                                                                            15.0)
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  color: hexToColor(
                                                                      global
                                                                          .brand_color_primary_action),
                                                                  //                                                gradient: LinearGradient(
                                                                  //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                                ),
                                                              )
                                                            : Text(''),
                                                      ),
                                                    ))
                                                  : Container(child: Text('hi')),

                                          //
                                          shiftsByDate.values.toList()[position][index].reported_timesheet ==
                                                  null
                                              ? Container(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      var prefs = await SharedPreferences.getInstance();
                                                      if (prefs.getString('shiftCancellationMessage') != null) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                              return AlertDialog(                                                              
                                                                content: Text(prefs.getString('shiftCancellationMessage')),
                                                                actions: <Widget>[
                                                                  FlatButton(
                                                                    child: Text('Ok'),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                          }
                                                        );
                                                      }                                                                                                                                                                  
                                                      shiftPosts(
                                                          shiftsByDate.values.toList()[position][index].id,
                                                          'cancel',
                                                          now);
                                                      /* ******** */
                                                      checkStorage();
                                                      gridViewWidget();
                                                      //                                          print('page loaded again');
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.all(0.0),
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        height: 40.0,
                                                        width: 90.0,
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              letterSpacing: 0.2,
                                                              fontFamily: "Sans",
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight.w600),
                                                        ),
                                                        alignment:
                                                            FractionalOffset.center,
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.black38,
                                                                blurRadius: 15.0)
                                                          ],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0),
                                                          color:
                                                              hexToColor('#EEEEEE'),
                                                          //                                                gradient: LinearGradient(
                                                          //                                                    colors: <Color>[Color(0xFFFF5252), Color(0xFFFF5252)])
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  child: Text(''),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                /// Set Animation image to detailProduk layout
                              ],
                            ),
                          ],
                        ),
                      ),
                      //
                    ),
                  ),
                  //      ),
                );
              })
          ) : DateTime.parse(shiftsByDate.keys.toList()[position]).day.toString() == (_dateFilter.toString()) ? StickyHeader(
            key: UniqueKey(),
            header: Container(
              margin: EdgeInsets.only(left: 10.0, top: 0.0, bottom: 5.0),
              color: Colors.black54,
              alignment: Alignment.center,
              height: 70.0,
              width: 70.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    formatterMonth.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                    style: TextStyle(color: Colors.white, fontSize: 15.0, fontFamily: "Gotik",),                 
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(
                          formatterDayWeek.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                          style: TextStyle(color: Colors.white, fontSize: 15.0,  fontFamily: "Gotik"),                  
                          textAlign: TextAlign.center,
                        ),
                      ), 
                      Text(
                        formatterDay.format(DateTime.parse(shiftsByDate.keys.toList()[position])),
                        style: TextStyle(color: Colors.white, fontSize: 15.0, fontFamily: "Gotik",),                 
                        textAlign: TextAlign.center,
                      ),                        
                    ],
                  ) 
                ],
              )                
            ),
            content: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0),
              itemCount: shiftsByDate.values.toList()[position].length,
              itemBuilder: (context, index) {
                return Padding(
                  key: UniqueKey(),
                  padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                  child: Material(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        margin: EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            //                          border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0)),
                            //                          borderRadius: BorderRadius.only(Rad),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFDDE4F0).withOpacity(1.0),
                                blurRadius: 10.0,
                                spreadRadius: 10.0,
                                //           offset: Offset(4.0, 10.0)
                              )
                            ]),
                        child: Column(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context).size.width *
                                              0.58,
                                          //                                       width: 300,
                                          child: Text(
                                            shiftsByDate.values.toList()[position][index].job_type,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(
                                                letterSpacing: 0.0,
                                                color: Colors.blueAccent,
                                                fontFamily: "Sans",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 22.0),
                                          ),
                                        ),
                                        Text(
                                          shiftsByDate.values.toList()[position][index].client_name,
                                          style: TextStyle(
                                            fontFamily: "Sans",
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.0,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          width: 55.0,
                                          padding: EdgeInsets.only(right: 20),
                                          height: 45.0,
                                          decoration: new BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image: new DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: new NetworkImage(
                                                      shiftsByDate.values.toList()[position][index]
                                                          .banner_image)))),
                                    ),
                                  ],
                                ),
                                /* Date and Time */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    //                                     Text(i.start),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0.0, top: 10.0, bottom: 10.0),
                                      child: Row(
                                        //                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                        //                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[                                           
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
                                                //                          border: Border.all(color: Colors.blueAccent),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5.0),
                                                    bottomRight:
                                                        Radius.circular(5.0),
                                                    topLeft: Radius.circular(5.0),
                                                    topRight: Radius.circular(5.0)),
                                                //                          borderRadius: BorderRadius.only(Rad),
                                              ),
                                              padding:
                                                  EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              height: 30,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        5, 0, 5, 0),
                                                    margin: EdgeInsets.fromLTRB(
                                                        2, 0, 3, 0),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                          //                                              right: BorderSide(width: 1.0, color: Colors.black12),
                                                          //                                              left: BorderSide(width: 1.0, color: Colors.black12),
                                                          ),
                                                    ),
                                                    child: Text(
                                                        formatterTime.format(
                                                            DateTime.parse(
                                                                shiftsByDate.values.toList()[position][index]
                                                                    .start)),
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            fontSize: 17,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700)),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                    //
                                                    child: Text('-',
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            fontSize: 17,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700)),
                                                  ),
                                                  Text(
                                                      formatterTime.format(
                                                          DateTime.parse(
                                                              shiftsByDate.values.toList()[position][index]
                                                                  .end)),
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 17,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ],
                                              ),
                                            ),
                                            flex: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                /* Direction */
                                FlatButton(
                                  padding:
                                      EdgeInsets.only(left: 0.0, top: 0.0),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute<void>(
                                            builder: (BuildContext
                                                    context) =>
                                                MapPage(shiftListHolder: shiftsByDate.values.toList()[position][index],)));
                                  },
                                  child: Container(
                                    child: Row(
                                      //                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.blueAccent,
                                          size: 24.0,
                                        ),
                                        SizedBox(
                                          height: 28.0,
                                          child: new Center(
                                            child: new Container(
                                              margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                              width: 1.0,
                                              height: 28.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: AutoSizeText(
                                            shiftsByDate.values.toList()[position][index]
                                                .address,
                                            maxLines: 2,
                                            minFontSize: 13.0,
                                            maxFontSize: 15.0,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,                                                              
                                                fontFamily:
                                                    "Gotik",
                                                color: Colors
                                                    .black54,
                                                letterSpacing: 0,
                                                fontSize: 15.0,
                                                wordSpacing: 0),
                                            textAlign:
                                                TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                    /* flex: 3, */
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 7.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[                                
                                      shiftsByDate.values.toList()[position][index].contact_name != null && shiftsByDate.values.toList()[position][index].contact_name.isNotEmpty ?
                                      Expanded(                                  
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.supervised_user_circle,
                                              color: Colors.blueAccent,
                                              size: 24.0,
                                            ),
                                            SizedBox(
                                              height: 28.0,
                                              child: new Center(
                                                child: new Container(
                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                  width: 1.0,
                                                  height: 28.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 1),
                                                    child: Text(
                                                      "Contact Name:",
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                          letterSpacing: 0.0,
                                                          wordSpacing: 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width * .30,
                                                    padding: EdgeInsets.only(left: 1),
                                                    child: Text(

                                                      shiftsByDate.values.toList()[position][index].contact_name !=
                                                              null
                                                          ? shiftsByDate.values.toList()[position][index]
                                                              .contact_name
                                                          : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(

                                                          fontFamily: "Gotik",
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.black54,
                                                          letterSpacing: 0.1,
                                                          fontSize: 15.0,
                                                          wordSpacing: 0.2),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        flex: 1,
                                      ):
                                      Text(''),
                                      shiftsByDate.values.toList()[position][index].contact_number != null  && shiftsByDate.values.toList()[position][index].contact_number.isNotEmpty
                                      ?
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.contact_phone,
                                              color: Colors.blueAccent,
                                              size: 24.0,
                                            ),
                                            SizedBox(
                                              height: 28.0,
                                              child: new Center(
                                                child: new Container(
                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                  width: 1.0,
                                                  height: 28.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            FlatButton(
                                              padding: EdgeInsets.all(0.0),
                                              onPressed: () async {
                                                UrlLauncher.launch('tel:+${shiftsByDate.values.toList()[position][index].contact_number.toString()}');
                                              },  
                                                                                      
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.30,
                                                        padding: EdgeInsets.only(left: 1),
                                                        child: Text(
                                                          "Contact Number:",
                                                          style: TextStyle(
                                                              fontFamily: "Gotik",
                                                              color: Colors.black54,
                                                              letterSpacing: 0.0,
                                                              fontSize: 12,
                                                              wordSpacing: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 1),
                                                        child: Text(
                                                          shiftsByDate.values.toList()[position][index].contact_number !=
                                                                  null
                                                              ? shiftsByDate.values.toList()[position][index]
                                                                  .contact_number
                                                              : '',
                                                          style: TextStyle(
                                                              fontFamily: "Gotik",
                                                              fontWeight: FontWeight.w600,                                                    
                                                              color: Colors.black54,
                                                              letterSpacing: 0.1,
                                                              fontSize: 15,
                                                              wordSpacing: 0.2),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ),
                                          ],
                                        ),
                                        flex: 1,
                                      ):
                                      Text('') 
                                    ],
                                  ),
                                ),                                 
                                Padding(
                                  padding: EdgeInsets.all(0.0),                                  
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(                                        
                                      border: Border(
                                        top: BorderSide(
                                            width: 1.0,
                                            color: Colors.blueAccent),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            final Event shift = Event(
                                              title: shiftsByDate.values.toList()[position][index].job_type,
                                              description: 'Shift at ${global.brand_name}, working as ${shiftsByDate.values.toList()[position][index].job_type}',
                                              location: shiftsByDate.values.toList()[position][index].address,
                                              startDate: DateTime.parse(shiftsByDate.values.toList()[position][index].start),
                                              endDate: DateTime.parse(shiftsByDate.values.toList()[position][index].end),
                                            );     
                                            Add2Calendar.addEvent2Cal(shift);                                     
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(Icons.event, color: Colors.blueAccent,),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5.0),
                                                child: Text(
                                                  'Add shift to calendar',
                                                  style: TextStyle(
                                                    fontFamily: 'Gotik',
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              ),                                            
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (builder) {
                                                return Container(                                      
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
                                                  child: new ListView(                                                
                                                    children: <Widget>[
                                                      /* PAY RATE */
                                                      shiftsByDate.values.toList()[position][index].campaign.pay_rate != null && shiftsByDate.values.toList()[position][index].campaign.pay_rate.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 20.0, left: 20.0),
                                                        child: Text(
                                                            'Pay Rate',
                                                            style:
                                                            _subHeaderCustomStyle,
                                                          ),
                                                      ) : Container(height: 0.0,),
                                                      shiftsByDate.values.toList()[position][index].campaign.pay_rate != null && shiftsByDate.values.toList()[position][index].campaign.pay_rate.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[                                                        
                                                            Icon(
                                                              Icons.monetization_on,
                                                              color: Colors.blueAccent,
                                                              size: 24.0,
                                                            ),
                                                            SizedBox(
                                                              height: 28.0,
                                                              child: new Center(
                                                                child: new Container(
                                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                  width: 1.0,
                                                                  height: 28.0,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.only(top: 0.0,left: 0.0,right: 0.0,bottom: 0.0),
                                                                child: AutoSizeText(
                                                                    '\$${shiftsByDate.values.toList()[position][index].campaign.pay_rate}/hr',
                                                                    style: TextStyle(
                                                                      fontFamily: "Gotik",
                                                                      fontSize: 20.0,
                                                                      color: Colors.black54,
                                                                      letterSpacing: 0.3,
                                                                      wordSpacing: 0.5
                                                                    )
                                                                  ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ) : Container(height: 0.0,),
                                                      /* INSTRUCTION */
                                                      shiftsByDate.values.toList()[position][index].post_instruction != null && shiftsByDate.values.toList()[position][index].post_instruction.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 20.0, left: 20.0),
                                                        child: Text(
                                                            'Instruction',
                                                            style:
                                                            _subHeaderCustomStyle,
                                                          ),
                                                      ) : Container(height: 0.0,),
                                                      shiftsByDate.values.toList()[position][index].post_instruction != null && shiftsByDate.values.toList()[position][index].post_instruction.isNotEmpty ?                                                     
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[                                                        
                                                            Icon(
                                                              Icons.supervised_user_circle,
                                                              color: Colors.blueAccent,
                                                              size: 24.0,
                                                            ),
                                                            SizedBox(
                                                              height: 28.0,
                                                              child: new Center(
                                                                child: new Container(
                                                                  margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                  width: 1.0,
                                                                  height: 28.0,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.only(top: 0.0,left: 0.0,right: 0.0,bottom: 0.0),
                                                                child: AutoSizeText(
                                                                    shiftsByDate.values.toList()[position][index]
                                                                        .post_instruction,
                                                                    style: _detailText),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ) : Container(height: 0.0,),  
                                                      /* NOTES */  
                                                      shiftsByDate.values.toList()[position][index].campaign.notes != null && shiftsByDate.values.toList()[position][index].campaign.notes.isNotEmpty ?                                                       
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            left: 20.0, top: 20.0),
                                                        child: Text(
                                                          'Notes',
                                                          style: _subHeaderCustomStyle,
                                                        ),  
                                                      ) : Container(height: 0.0,),                                                                                                                                              
                                                      shiftsByDate.values.toList()[position][index].campaign.notes != null && shiftsByDate.values.toList()[position][index].campaign.notes.isNotEmpty ?                                                     
                                                      Container(
                                                        width: MediaQuery.of(context).size.width * 0.9,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0, bottom: 20.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[  
                                                              Icon(
                                                                Icons.speaker_notes,
                                                                color: Colors.blueAccent,
                                                                size: 24.0,
                                                              ),
                                                              SizedBox(
                                                                height: 28.0,
                                                                child: new Center(
                                                                  child: new Container(
                                                                    margin: new EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                                                                    width: 1.0,
                                                                    height: 28.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),                                                                                                        
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 0.0,
                                                                      left: 0.0),
                                                                  child: AutoSizeText(
                                                                    shiftsByDate.values.toList()[position][index].campaign.notes,
                                                                    style: _detailText,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ) : Container(height: 0.0,),                                                  
                                                    ],
                                                  ),
                                                );
                                              });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                'More Info',
                                                style: TextStyle(
                                                  fontFamily: 'Gotik',
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down, color: Colors.blueAccent,)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ),                        
                                shiftsByDate.values.toList()[position][index].reported_timesheet != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          //                                     Text(i.start),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                left: 0.0,
                                                right: 0.0,
                                                top: 15.0,
                                                bottom: 4),
                                            margin: EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.black12),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  //                                        width:MediaQuery.of(context).size.width*0.25,
                                                  child: Text('Checked in :',
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                                  margin: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                                  child: Text(
                                                      formatterTime.format(DateTime
                                                          .parse(shiftsByDate.values.toList()[position][index]
                                                              .reported_timesheet
                                                              .timein)),
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          shiftsByDate.values.toList()[position][index]
                                                      .reported_timesheet
                                                      .timeout !=
                                                  null
                                              ? Container(
                                                  padding: const EdgeInsets.only(
                                                      left: 0.0,
                                                      right: 0.0,
                                                      top: 15.0,
                                                      bottom: 15),
                                                  margin: EdgeInsets.only(top: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.black12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        //                                        width:MediaQuery.of(context).size.width*0.25,
                                                        child: Text('Checked out :',
                                                            style: TextStyle(
                                                                fontFamily: "Gotik",
                                                                fontSize: 15,
                                                                color: Colors.black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 0, 5, 0),
                                                        margin: EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                        child: Text(
                                                            formatterTime.format(
                                                                DateTime.parse(models[
                                                                        position]
                                                                    .reported_timesheet
                                                                    .timeout)),
                                                            style: TextStyle(
                                                                fontFamily: "Gotik",
                                                                fontSize: 15,
                                                                color: Colors.black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(child: Text('')),
                                        ],
                                      )
                                    : Container(
                                        child: Text(''),
                                      ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    //                                     Text(i.start),
                                    Container(
                                      //                                decoration: Border(top: ),
                                      margin: EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              width: 1.0, color: Colors.black12),
                                        ),
                                      ),
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0.0, top: 5.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          shiftsByDate.values.toList()[position][index].reported_timesheet ==
                                                  null
                                              ?

                                              //                                    formatter.format(DateTime.parse(shiftsByDate.values.toList()[position][index].start)) == DateTime.now() ?
                                              Container(
                                                  child: DateTime.parse(
                                                                  shiftsByDate.values.toList()[position][index]
                                                                      .start)
                                                              .difference(
                                                                  DateTime.now())
                                                              .inHours <=
                                                          28
                                                      ? InkWell(
                                                          onTap: () {
                                                            //                                          shiftPosts(shiftsByDate.values.toList()[position][index].id , 'check-in' , now);
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                  context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    'Are you sure you want to check in?',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17.0),
                                                                  ),
                                                                  //                          content: Text(successInformation['message']),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      child: Text(
                                                                          'No'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(
                                                                                context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    FlatButton(
                                                                      child: Text(
                                                                          'Yes'),
                                                                      onPressed:
                                                                          () {
                                                                        shiftPosts(
                                                                            shiftsByDate.values.toList()[position][index]
                                                                                .id,
                                                                            'check-in',
                                                                            now);
                                                                        setState(
                                                                            () {
                                                                          /* ********* */
                                                                          checkStorage();
                                                                          gridViewWidget();
                                                                        });

                                                                        //                                                      print('page loaded again');
                                                                        Navigator.of(
                                                                                context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(0.0),
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                      top: 10),
                                                              height: 40.0,
                                                              width:
                                                                  shiftsByDate.values.toList()[position][index]
                                                                          .isCheckIn
                                                                      ? 90.0
                                                                      : 190,
                                                              child: Text(
                                                                'Check-in',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.2,
                                                                    fontFamily:
                                                                        "Sans",
                                                                    fontSize: 14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              alignment:
                                                                  FractionalOffset
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      blurRadius:
                                                                          15.0)
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: hexToColor(global
                                                                    .brand_color_primary_action),
                                                                //                                                gradient: LinearGradient(
                                                                //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : shiftsByDate.values.toList()[position][index]
                                                                  .reported_timesheet !=
                                                              null
                                                          ? InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                        'Are you sure you want to check out?',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17.0),
                                                                      ),
                                                                      //                          content: Text(successInformation['message']),
                                                                      actions: <
                                                                          Widget>[
                                                                        FlatButton(
                                                                          child: Text(
                                                                              'No'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                        FlatButton(
                                                                          child: Text(
                                                                              'Yes'),
                                                                          onPressed:
                                                                              () {
                                                                            print(
                                                                                'hi');
                                                                            shiftPosts(
                                                                                shiftsByDate.values.toList()[position][index].id,
                                                                                'check-out',
                                                                                now);
                                                                            setState(
                                                                                () {
                                                                              /* ***** */
                                                                              checkStorage();
                                                                              gridViewWidget();
                                                                            });

                                                                            print(
                                                                                'page loaded again');
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                        )
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        0.0),
                                                                child: shiftsByDate.values.toList()[position][index]
                                                                            .reported_timesheet
                                                                            .timeout ==
                                                                        null
                                                                    ? Container(
                                                                        margin: EdgeInsets
                                                                            .only(
                                                                                top:
                                                                                    10),
                                                                        height:
                                                                            40.0,
                                                                        width:
                                                                            120.0,
                                                                        child: Text(
                                                                          'Check out',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              letterSpacing:
                                                                                  0.2,
                                                                              fontFamily:
                                                                                  "Sans",
                                                                              fontSize:
                                                                                  14.0,
                                                                              fontWeight:
                                                                                  FontWeight.w600),
                                                                        ),
                                                                        alignment:
                                                                            FractionalOffset
                                                                                .center,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color:
                                                                                    Colors.black38,
                                                                                blurRadius: 15.0)
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  10.0),
                                                                          color: hexToColor(
                                                                              global
                                                                                  .brand_color_primary_action),
                                                                          //                                                gradient: LinearGradient(
                                                                          //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                                        ),
                                                                      )
                                                                    : Text(''),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                if (!(shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0))) {
                                                                  shiftPosts(
                                                                        shiftsByDate.values.toList()[position][index]
                                                                            .id,
                                                                        'confirm',
                                                                        now)
                                                                    .then(
                                                                        (response) {});
                                                                }      
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        0.0),
                                                                child: Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top: 10),
                                                                  height: 40.0,
                                                                  width: 90.0,
                                                                  child: Text(
                                                                    (shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0)) ?
                                                                    'Confirmed' : 'Confirm',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.2,
                                                                        fontFamily:
                                                                            "Sans",
                                                                        fontSize:
                                                                            14.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600),
                                                                  ),
                                                                  alignment:
                                                                      FractionalOffset
                                                                          .center,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .black38,
                                                                          blurRadius:
                                                                              15.0)
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10.0),
                                                                    color: hexToColor(
                                                                        global
                                                                            .brand_color_primary_action/* '#195e83' */).withOpacity((shiftsByDate.values.toList()[position][index].tender.availability_freshness != null && (now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours < 3 && now.difference(DateTime.parse(shiftsByDate.values.toList()[0][0].tender.availability_freshness)).inHours >= 0)) ? 0.5 : 1.0),
                                                                    //                                               gradient: LinearGradient(
                                                                    //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                )
                                              : shiftsByDate.values.toList()[position][index]
                                                          .reported_timesheet !=
                                                      null
                                                  ? Container(
                                                      child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                'Are you sure you want to check out?',
                                                                style: TextStyle(
                                                                    fontSize: 17.0),
                                                              ),
                                                              //                          content: Text(successInformation['message']),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text('No'),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                FlatButton(
                                                                  child:
                                                                      Text('Yes'),
                                                                  onPressed: () {
                                                                    print('hi');
                                                                    shiftPosts(
                                                                        shiftsByDate.values.toList()[position][index]
                                                                            .id,
                                                                        'check-out',
                                                                        now);
                                                                    setState(() {
                                                                      /* ****** */
                                                                      checkStorage();
                                                                      gridViewWidget();
                                                                    });

                                                                    print(
                                                                        'page loaded again');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        child: shiftsByDate.values.toList()[position][index]
                                                                    .reported_timesheet
                                                                    .timeout ==
                                                                null
                                                            ? Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                        top: 10),
                                                                height: 40.0,
                                                                width: 120.0,
                                                                child: Text(
                                                                  'Check out',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          0.2,
                                                                      fontFamily:
                                                                          "Sans",
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                alignment:
                                                                    FractionalOffset
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .black38,
                                                                        blurRadius:
                                                                            15.0)
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  color: hexToColor(
                                                                      global
                                                                          .brand_color_primary_action),
                                                                  //                                                gradient: LinearGradient(
                                                                  //                                                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                                                ),
                                                              )
                                                            : Text(''),
                                                      ),
                                                    ))
                                                  : Container(child: Text('hi')),

                                          //
                                          shiftsByDate.values.toList()[position][index].reported_timesheet ==
                                                  null
                                              ? Container(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      var prefs = await SharedPreferences.getInstance();
                                                      if (prefs.getString('shiftCancellationMessage') != null) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                              return AlertDialog(                                                              
                                                                content: Text(prefs.getString('shiftCancellationMessage')),
                                                                actions: <Widget>[
                                                                  FlatButton(
                                                                    child: Text('Ok'),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                          }
                                                        );
                                                      }  
                                                      shiftPosts(
                                                          shiftsByDate.values.toList()[position][index].id,
                                                          'cancel',
                                                          now);
                                                      /* ******** */
                                                      checkStorage();
                                                      gridViewWidget();
                                                      //                                          print('page loaded again');
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.all(0.0),
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        height: 40.0,
                                                        width: 90.0,
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              letterSpacing: 0.2,
                                                              fontFamily: "Sans",
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight.w600),
                                                        ),
                                                        alignment:
                                                            FractionalOffset.center,
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.black38,
                                                                blurRadius: 15.0)
                                                          ],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0),
                                                          color:
                                                              hexToColor('#EEEEEE'),
                                                          //                                                gradient: LinearGradient(
                                                          //                                                    colors: <Color>[Color(0xFFFF5252), Color(0xFFFF5252)])
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  child: Text(''),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                /// Set Animation image to detailProduk layout
                              ],
                            ),
                          ],
                        ),
                      ),
                      //
                    ),
                  ),
                  //      ),
                );
              })
          ) : Container(height: 0.0);          
        }
      ),
      onRefresh: () async {
        await HttpRequests().getUpcomingShifts().then((shifts) {
          setState(() {
            models = shifts;
            groupShiftsByDate(models);  
            if (models.length == 0) {
              _isVisible = !_isVisible;
            }
          });          
        });
      },
      key: _refreshIndicatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double size = mediaQueryData.size.height;

    /// Navigation to MenuDetail.dart if user Click icon in category Menu like a example camera
    var onClickMenuIcon = () {
      Navigator.of(context).push(PageRouteBuilder(
//          pageBuilder: (_, __, ___) => new menuDetail(),
          transitionDuration: Duration(milliseconds: 750),

          /// Set animation with opacity
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    /// Navigation to promoDetail.dart if user Click icon in Week Promotion
    var onClickWeekPromotion = () {
      Navigator.of(context).push(PageRouteBuilder(
//          pageBuilder: (_, __, ___) => new promoDetail(),
          transitionDuration: Duration(milliseconds: 750),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    /// Navigation to categoryDetail.dart if user Click icon in Category
    var onClickCategory = () {
      Navigator.of(context).push(PageRouteBuilder(
//          pageBuilder: (_, __, ___) => new categoryDetail(),
          transitionDuration: Duration(milliseconds: 750),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    /// Declare device Size
    var deviceSize = MediaQuery.of(context).size;

    return EasyLocalizationProvider(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE4F0),
        appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          backgroundColor: hexToColor(global.brand_color_bg_light),
          centerTitle: true,
          elevation: 0.0,
          title: new Text(
            'Upcoming Shifts',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Gotik', fontSize: 16.0),
          ),

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
                    child: Stack(
                      alignment: AlignmentDirectional(-3.0, -3.0),
                      children: <Widget>[
                        Image.asset(
                          "assets/img/notifications-button.png",
                          height: 24.0,
                        ),
                        CircleAvatar(
                          radius: 8.6,
                          backgroundColor: Colors.redAccent,
                          child: Text(
                            _totalCount.toString(),
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
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

        /// Use Stack to costume a appbar
        body: Stack(
          children: <Widget>[
            Visibility(
                visible: _isVisible,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.07,
                          margin: EdgeInsets.only(bottom: 10.0),  
                          height: 45.0,  
                          color: Colors.white,
                          child: Icon(Icons.keyboard_arrow_left, color: Colors.grey,)
                        ),
                        Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 10.0),     
                          child: Column(
                            children: <Widget>[                                                 
                              Container(      
                                width: MediaQuery.of(context).size.width * 0.86,
                                height: 45.0,                  
                                margin: EdgeInsets.only(top: 0.0),                            
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 30,
                                  itemBuilder: (context, index) {                                
                                    return Stack(                                      
                                      children: <Widget>[                                    
                                        Container(   
                                          padding: EdgeInsets.only(top: 3.0),
                                          decoration: BoxDecoration(
                                            color: selectedDay[index] == true ? hexToColor(/* global.brand_color_secondary_action */'#195e83'): Colors.transparent,                                                 
                                            /* border: Border(
                                              bottom: BorderSide(width: 2.0, color: Colors.blue)
                                            ) */
                                          ),                                  
                                          width: MediaQuery.of(context).size.width * 0.13,
                                          child: FlatButton(
                                            padding: EdgeInsets.symmetric(horizontal: 0.0),
                                            onPressed: () {
                                              setState(() {                                                                                
                                                if (selectedDay[index] == true) {
                                                  for (var i = 0; i < selectedDay.length; i++) {
                                                    selectedDay[i] = false;
                                                  }  
                                                  _dateFilter = null;
                                                } else {
                                                  _dateFilter = formatterDay.format(addDayToNow(index));  
                                                  for (var i = 0; i < selectedDay.length; i++) {
                                                    selectedDay[i] = false;
                                                  }  
                                                  selectedDay[index] = true;
                                                }              
                                              });
                                            },
                                            child: Column(
                                              children: <Widget>[
                                                Text(formatterMonth.format(addDayToNow(index)).toString(), style: TextStyle(color: selectedDay[index] == true ? Colors.white : Colors.black, fontFamily: "Gotik", fontSize: 12.0)),
                                                Text(formatterDay.format(addDayToNow(index)).toString(), style: TextStyle(color: selectedDay[index] == true ? Colors.white : Colors.black, fontFamily: "Gotik"))
                                              ],
                                            )
                                          ),
                                        ),
                                        daysWithShifts.contains(formatterBasic.format(addDayToNow(index))) ?
                                        Positioned.fill(                                      
                                          /* left: MediaQuery.of(context).size.width * 0.7, */
                                          top: 31.0,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(                                        
                                              width: 5.0,
                                              height: 5.0,
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent,
                                                shape: BoxShape.circle
                                              ),
                                            )
                                          ),
                                        ) : Container(height: 0.0,)
                                      ],
                                    );
                                  },                              
                                ),
                              ),                           
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.07,
                          margin: EdgeInsets.only(bottom: 10.0),  
                          color: Colors.white,
                          height: 45.0,  
                          child: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                        ),
                      ],
                    ),                    
                    Expanded(
                      child: gridViewWidget(),
                    )
                  ],
                ),
                replacement: /* Card(
                  child: new ListTile(
                    title: Center(
                      child: new Text('No Upcoming shifts '),
                    ),
                  ),
                ) */
                EmptyScreen(),
              ),

            /// Get a class AppbarGradient
            /// This is a Appbar in home activity
//            AppbarGradient(),
          ],
        ),
      ),
    );
  }
}
