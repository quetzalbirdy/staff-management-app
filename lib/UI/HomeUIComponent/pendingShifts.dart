import 'dart:convert';
import 'dart:io';

import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Map.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/ReportedTimesheet.dart';
import 'package:wolf_jobs/model/PendingShiftsHolder.dart';
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
/* import 'package:geolocator/geolocator.dart'; */
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
import 'package:path_provider/path_provider.dart';

class PendingShifts extends StatefulWidget {
  final HttpService httpService = HttpService();

  @override
  _PendingShiftsState createState() => _PendingShiftsState();
}

/// Component all widget in home
class _PendingShiftsState extends State<PendingShifts> with TickerProviderStateMixin {
  /// Declare class GridItem from HomeGridItemReoomended.dart in folder ListItem
//  GridItem gridItem;
  var now = new DateTime.now();
  var formatter = new DateFormat('yMMMd');
  var formatterTime = new DateFormat('kk:mm:a');
  bool isStarted = false;
  bool _checkUser = false;
  bool _isVisible = true;
  bool isConfirm = true;

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

  var _checkUserName;
  var _checkCoordinates = "";
  String _checkUserId = "";
  String _checkUserType = "";
  String _checkUserCode = "";
  String _checkUserTypeCode = "";
  bool subscriptionState;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  trackSegment() {
    Segment.track(
        eventName: 'View Pending Shifts', properties: {'Source': 'Native apps'});
  }

  checkLastApiCall() async {
    var lastCallFile = await JsonStorage('lastPendingShiftsCall').readFile();
    DateTime now = DateTime.now();
    /* print(now.difference(DateTime.parse('2020-06-02 00:15:50.049789')).inMinutes); */
    if (lastCallFile == 'no file') {
      checkStorage();
      print(now);
      await JsonStorage('lastPendingShiftsCall').writeFile(now.toString());
    } else {
      if (now.difference(DateTime.parse(lastCallFile)).inMinutes > 4) {
        await JsonStorage('lastPendingShiftsCall').writeFile(now.toString());
        checkStorage();        
      } else {
        checkStorage(true);                
      }
    }
  }

  checkStorage([apiCall]) async {
    var upcomingShiftsStorage = await JsonStorage('pendingShifts').readFile();
    List<PendingShiftsHolder> response = [];
    if (upcomingShiftsStorage == 'no file') {
      HttpRequests().getPendingShifts().then((shifts) {
        setState(() {
          models = shifts;
          if (models.length == 0) {
            _isVisible = false;
          }
        });
      });
    } else {
      List<dynamic> dataHolder = json.decode(upcomingShiftsStorage)['data']['shifts'];
      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder.toList()[j];
          var dataSort = dataHolder.toList();
          dataSort.sort((a, b) {
            var adate = a['start']; //before -> var adate = a.expiry;
            var bdate = b['start']; //before -> var bdate = b.expiry;
            return adate.compareTo(
                bdate); //to get the order other way just switch `adate & bdate`
          });          
          PendingShiftsHolder models = PendingShiftsHolder.fromJson(dataSort[j]);
          var data = dataHolder.toList()[j];

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
        });
        if (apiCall == null) {
          HttpRequests().getPendingShifts().then((shifts) {
            setState(() {
              models = shifts;
              /* showToast("Updated", duration: 2, gravity: Toast.TOP); */
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

  List<PendingShiftsHolder> models = [];
  List<Campaign> responseShift = [];
  List<ReportedTimesheet> responseTimesheet = [];

  /* getPosts() async {
    final String postsURL =
        "http://ondemandstaffing.app/api/v1/shifts/view_all_upcoming_assigned_jobs/?tenant=" + tenant;
    List<PendingShiftsHolder> response = [];
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

          PendingShiftsHolder models = PendingShiftsHolder.fromJson(dataSort[j]);
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
    /* Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); */    
    Location location = new Location();    

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      /* if (!_serviceEnabled) {
        return;
      } */
    } 

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      /* if (_permissionGranted != PermissionStatus.granted) {
        return;
      } */
    }

    if (_serviceEnabled) {
      _locationData = await location.getLocation();
      print('location: ${_locationData.latitude}');
    }

    

    var token = sharedPreferences.getString("token");
     Map<String, dynamic> data;
    if (_locationData != null){
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
      var responseJson = jsonDecode(res.body);      

      showToast(responseJson['message'], duration: 4, gravity: Toast.BOTTOM);
      setState(() {        
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
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

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
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          itemCount: models.length,
          itemBuilder: (context, position) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
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
                                        models[position].title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                            letterSpacing: 0.0,
                                            color: Colors.blueAccent,
                                            fontFamily: "Gothik",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22.0),
                                      ),
                                    ),
                                    Text(
                                      models[position].client,
                                      style: TextStyle(
                                        fontFamily: "Gothik",
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.0,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                                /* Align(
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
                                                  models[position]
                                                      .banner_image)))),
                                ) */
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '\$${models[position].price}/hr',
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontFamily: "Gothik",
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.0, bottom: 50)),
                                    /* models[position]
                                        .post_instruction.isNotEmpty &&
                                    models[position]
                                        .post_instruction !=
                                        null ?
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (builder) {
                                                return SingleChildScrollView(
                                                  child: Container(
                                                    color: Colors.black26,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 2.0),
                                                      child: Container(
                                                        height: 1500.0,
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
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                                padding:
                                                                EdgeInsets.only(
                                                                    top: 20.0)),
                                                            Center(
                                                                child: Text(
                                                                  'Post Instruction',
                                                                  style:
                                                                  _subHeaderCustomStyle,
                                                                )),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0,
                                                                  left: 20.0,
                                                                  right: 20.0,
                                                                  bottom: 20.0),
                                                              child: Text(
                                                                  models[position]
                                                                      .post_instruction,
                                                                  style: _detailText),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20.0),
                                                              child: Text(
                                                                'Notes',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    "Gotik",
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                    fontSize: 15.0,
                                                                    color:
                                                                    Colors.black,
                                                                    letterSpacing:
                                                                    0.3,
                                                                    wordSpacing: 0.5),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 20.0,
                                                                  left: 20.0),
                                                              child: Text(
                                                                models[position]
                                                                    .campaign
                                                                    .notes,
                                                                style: _detailText,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.description,
                                              color: Colors.blueAccent,
                                              size: 20.0,
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
                                                      "Instruction:",
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          color: Colors.black54,
                                                          fontSize: 12,
                                                          letterSpacing: 0.0,
                                                          wordSpacing: 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        0.273,
                                                    padding: EdgeInsets.only(left: 1),
                                                    child: Text(
                                                      models[position]
                                                          .post_instruction !=
                                                          null
                                                          ? models[position]
                                                          .post_instruction
                                                          : '',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily: "Gotik",
                                                          color: Colors.black54,
                                                          fontSize: 12
                                                      //                                                  letterSpacing: 0.3,
                                                        //                                                  wordSpacing: 0.5
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      flex: 3,
                                    ):
                                    Text(''), */       
                                    Expanded(
                                      child: FlatButton(
                                        padding:
                                            EdgeInsets.only(left: 0.0, top: 0.0),
                                        onPressed: () async {                                        
                                          /* List<Placemark> placemark = await Geolocator().placemarkFromAddress(models[position].address); */
                                          var addresses = await Geocoder.local.findAddressesFromQuery(models[position].address);
                                          var first = addresses.first;
                                          print(first.coordinates.latitude);
                                          Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                  builder: (BuildContext
                                                          context) =>
                                                      MapPage(pendingShiftsHolder: models[position], addressCoord: addresses,)));
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
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.centerLeft,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 0),
                                                          child: Text(
                                                            models[position]
                                                                .address,
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
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                          /* flex: 3, */
                                        ),
                                      ),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      child: Row(
                                        //                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.sms_failed,
                                            color: Colors.blueAccent,
                                            size: 24.0,
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
                                                    "Status:",
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
                                                  /* width: MediaQuery.of(context).size.width * .32, */
                                                  padding: EdgeInsets.only(left: 1),
                                                  child: Text(

                                                    models[position].tender_status !=
                                                            null
                                                        ? models[position].tender_status[0].toUpperCase() + models[position].tender_status.substring(1)
                                                        : '',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600, 
                                                        fontFamily: "Gotik",
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
                                    ),                                                                                                     
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(top: 60.0)),
                                models[position].notes.isNotEmpty && models[position].notes !=
                                    null ?
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (builder) {
                                          return SingleChildScrollView(
                                            child: Container(
                                              color: Colors.black26,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0),
                                                child: Container(
                                                  height: 1500.0,
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
                                                  child: new Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: <Widget>[
                                                      Padding(
                                                          padding:
                                                          EdgeInsets.only(
                                                              top: 20.0)),
                                                      Center(
                                                          child: Text(
                                                            'Notes',
                                                            style:
                                                            _subHeaderCustomStyle,
                                                          )),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            top: 20.0,
                                                            left: 20.0,
                                                            right: 20.0,
                                                            bottom: 20.0),
                                                        child: Text(
                                                            models[position]
                                                                .notes,
                                                            style: _detailText),
                                                      ),                                                      
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.assignment,
                                          color: Colors.blueAccent,
                                          size: 20.0,
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
                                                  "Notes:",
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
                                                width: MediaQuery.of(context).size.width * .8,
                                                padding: EdgeInsets.only(left: 1),
                                                child: Text(

                                                  models[position].notes !=
                                                          null
                                                      ? models[position]
                                                          .notes
                                                      : '',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600, 
                                                      fontFamily: "Gotik",
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
                                    )
                                  ),
                                  flex: 3,
                                ):
                                Text(''),                                
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                //                                     Text(i.start),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0.0, top: 20.0),
                                  child: Row(
                                    //                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          width: 95,
                                          child: Text(
                                              formatter.format(DateTime.parse(models[position].start)),
                                              style: TextStyle(
                                                  fontFamily: "Gotik",
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        flex: 2,
                                      ),
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
                                                            models[position]
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
                                                          models[position]
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                //                                     Text(i.start),
                                Container(
                                  //                                decoration: Border(top: ),
                                  margin: EdgeInsets.only(top: 20),
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
                                        MainAxisAlignment.end,
                                    children: <Widget>[  
                                      models[position].tender_status == 'cancelled' || models[position].tender_status == 'dropped' ? 
                                      Container(
                                        child: InkWell(
                                          onTap: () {
                                            shiftPosts(
                                                    models[position]
                                                        .shift_id,
                                                    'apply',
                                                    now)
                                                .then(
                                                    (response) {});
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
                                                'Request',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white,
                                                    letterSpacing:
                                                        0.2,
                                                    fontFamily:
                                                        "Gothik",
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
                                                        .brand_color_secondary_action),
                                                //                                               gradient: LinearGradient(
                                                //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                              ),
                                            ),
                                          ),
                                        ),
                                      ) :                                                                                                               
                                      Container(
                                        child: InkWell(
                                          onTap: () {
                                            shiftPosts(
                                                models[position].shift_id,
                                                'cancel',
                                                now);                                            
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
                                                    fontFamily: "Gothik",
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
                                    ],
                                  ),
                                ),
                              ],
                            )
                            /* models[position].reported_timesheet != null
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
                                                      .parse(models[position]
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
                                      models[position]
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
                                  ), */

                            /* Column(
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
                                      models[position].reported_timesheet ==
                                              null
                                          ?

                                          //                                    formatter.format(DateTime.parse(models[position].start)) == DateTime.now() ?
                                          Container(
                                              child: DateTime.parse(
                                                              models[position]
                                                                  .start)
                                                          .difference(
                                                              DateTime.now())
                                                          .inHours <=
                                                      28
                                                  ? InkWell(
                                                      onTap: () {
                                                        //                                          shiftPosts(models[position].id , 'check-in' , now);
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
                                                                        models[position]
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
                                                              models[position]
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
                                                                    "Gothik",
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
                                                  : models[position]
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
                                                                            models[position].id,
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
                                                            child: models[position]
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
                                                                              "Gothik",
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
                                                            shiftPosts(
                                                                    models[position]
                                                                        .id,
                                                                    'confirm',
                                                                    now)
                                                                .then(
                                                                    (response) {});
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
                                                                'Confirm',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.2,
                                                                    fontFamily:
                                                                        "Gothik",
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
                                                                        .brand_color_secondary_action),
                                                                //                                               gradient: LinearGradient(
                                                                //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                            )
                                          : models[position]
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
                                                                    models[position]
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
                                                    child: models[position]
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
                                                                      "Gothik",
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
                                      models[position].reported_timesheet ==
                                              null
                                          ? Container(
                                              child: InkWell(
                                                onTap: () {
                                                  shiftPosts(
                                                      models[position].id,
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
                                                          fontFamily: "Gothik",
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
                            ), */

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
          }),
      onRefresh: () async {
        await HttpRequests().getPendingShifts().then((shifts) {
          setState(() {
            models = shifts;
            if (models.length == 0) {
              _isVisible = !_isVisible;
            }
          });
          /* showToast("Updated", duration: 2, gravity: Toast.TOP); */
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
            'Pending Shifts',
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

//              ],
        ),
        drawer: MainMenu(),

        /// Use Stack to costume a appbar
        body: Stack(
          children: <Widget>[
            Visibility(
                visible: _isVisible,
                child: gridViewWidget(),
                replacement: EmptyScreen(),),

            /// Get a class AppbarGradient
            /// This is a Appbar in home activity
//            AppbarGradient(),
          ],
        ),
      ),
    );
  }
}
