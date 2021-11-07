import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:wolf_jobs/Library/app-localizations.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Map.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/MapShift.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/timeSheet/editTimesheet.dart';
import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:http/http.dart';
/* import 'package:onesignal_flutter/onesignal_flutter.dart'; */
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/Api/jobs.dart';
import 'package:wolf_jobs/Library/carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/Library/countdown_timer/countDownTimer.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/DetailProduct.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/model/JobListHolder.dart';
import 'package:wolf_jobs/model/Shift.dart';
import 'package:intl/intl.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:toast/toast.dart';

class Menu extends StatefulWidget {
  final HttpService httpService = HttpService();

  @override
  _MenuState createState() => _MenuState();
}

/// Component all widget in home
class _MenuState extends State<Menu> with TickerProviderStateMixin {
  /// Declare class GridItem from HomeGridItemReoomended.dart in folder ListItem
//  GridItem gridItem;
  var now = new DateTime.now();
  var formatter = new DateFormat('yMMMd');
  var formatterTime = new DateFormat('kk:mm:a');
  var datePickerFormat = 'yyyy-MMMM-dd';
  var pickedDate;

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  bool isStarted = false;
  bool _checkUser = false;
  bool _isVisible = true;
  String CountNotice = "4";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();    
    /* getPosts().then((value) {
      print(value);
      /* getJobTypes(value); */
    }); */
    checkLastApiCall();
    /* checkNotificationStatus(); */
    _getEmail();
    getNotifications();
    setNotificationStatus();
    trackSegment();
    getDeclineReasons();
  }  

  List declineReasonsList = [];

  getDeclineReasons() async {
    var prefs = await SharedPreferences.getInstance();    
    var declineReasonsTempList = json.decode(prefs.getString('shiftDeclineReasons'));
    declineReasonsTempList.forEach((k,v) => declineReasonsList.add(v)); 
    print('Decine: $declineReasonsList');
  }

  void _showNotInterestedAlertDialog(shifts, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('You can find declined shifts in "Pending Shifts" screen'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                /* _showNotInterestedOptionsDialog(shifts, index); */
              },
            )
          ],
        );
      }
    );
  }

  String declineReason;

  void _showNotInterestedOptionsDialog(shifts, index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {        
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {              
              return Container(
                margin: new EdgeInsets.only(top: 5.0),
                child: Column(        
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,          
                  children: <Widget>[                            
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 0, left: 30.0, right: 30.0),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 10),
                        child: Text('Decline reason'),
                      ),
                    Container(                    
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.0),                        
                          color: Colors.white,                        
                          boxShadow: [
                            BoxShadow(blurRadius: 10.0, color: Colors.black12)
                          ]),
                      margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
                        alignment: AlignmentDirectional.center,
                        height: 60.0,

                        padding: EdgeInsets.only(left: 0.0, right: 10.0, top: 0.0, bottom: 0.0),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            width: 210.0,                     
                            child: DropdownButtonFormField<String>(      
                              hint: Text('Select a reason'),                      
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
                                /* labelText: models[position].question, */
                              ),
                              items: [
                                for (var reason in declineReasonsList) 
                                DropdownMenuItem<String>(                                
                                    value: reason,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            reason,
                                            style: TextStyle(
                                              color: Colors.black,  
                                              fontSize: 14.0                                            
                                            ),
                                          )
                                        ],
                                      )
                                      ),
                                  ),                                                             
                              ],
                              value: declineReason,                         
                              onChanged: (String newValue) {
                                setState(() {
                                  declineReason = newValue;
                                });                                
                              },                          
                            ),
                        ),
                      ],
                    )
                    )              
                ],
              ),
            );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  loaders[index] = false;
                });
              },
            ),
            FlatButton(
              child: Text('Decline'),
              onPressed: () async {
                if (declineReason != null) {
                  prefs = await SharedPreferences.getInstance();
                  await HttpRequests().declineShifts(shifts, declineReason).then((message) {
                    prefs.setString('firstNotInterested','true');
                    showToast(message);     
                    setState(() {
                      loaders[index] = false;
                      print(loaders);
                      declineReason = null;
                    });                                                                               
                  });                
                  checkStorage();
                  Navigator.of(context).pop();
                } else {
                  Flushbar(
            //        title:  responseJson['message'],
                    message: 'Please select a reason',
                    duration: Duration(seconds: 3),
                  )..show(context);
                }            
              },
            )
          ],
        );
      }
    );
  }
  

  bool isLoading = false;

  Widget actionButton(text) {
    return Padding(
      padding:
          EdgeInsets.all(
              0.0),
      child: Container(                
        height: 40.0,
        width: 90.0,
        child:  !isLoading ? Text(
          text,
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
        ) : Lottie.asset(Constants.buttonLoadingAnimation),
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
                  .brand_color_primary_action/* '#195e83' */)
          //                                               gradient: LinearGradient(
          //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
        ),
      ),
    );
    /* Container(
      height: 40.0,      
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: !isLoading ? Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(          
            color: Colors.white,
            height: 1.0,
            letterSpacing: 0.2,
            fontFamily: "Sans",
            fontSize: 15.0,
            fontWeight: FontWeight.w800),
      ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
              colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
    ); */
  }

  checkLastApiCall() async {
    var lastCallFile = await JsonStorage('lastAvailableShiftsCall').readFile();
    DateTime now = DateTime.now();
    /* print(now.difference(DateTime.parse('2020-06-02 00:15:50.049789')).inMinutes); */
    if (lastCallFile == 'no file') {
      checkStorage();
      print(now);
      await JsonStorage('lastAvailableShiftsCall').writeFile(now.toString());
    } else {
      if (now.difference(DateTime.parse(lastCallFile)).inMinutes > 4) {
        await JsonStorage('lastAvailableShiftsCall').writeFile(now.toString());
        checkStorage();
      } else {
        checkStorage(true);
      }
    }
  }

  var _checkUserName;
  var _checkCoordinates = "";
  String _checkUserId = "";
  String _checkUserType = "";
  String _checkUserCode = "";
  String _checkUserTypeCode = "";
  bool subscriptionState;

  trackSegment() {
    Segment.track(
        eventName: 'View Available Jobs',
        properties: {'Source': 'Native apps'});
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

    List<Notiification> responseNotification = [];
    final String postsURL =
        'https://svk2a7wbej.execute-api.us-east-1.amazonaws.com/prod/?data={"coordinates":"$_checkCoordinates","coordinates_type":"Onesignal","user_code":"$_checkUserCode","user_type":"$_checkUserType","user_type_code":"$_checkUserTypeCode","name":"$_checkUserName","tenant_key":"$tenant","subscribed":$subscriptionState}&key_action=update_coordinates&tenant=$tenant&api_key=value2';
    print(postsURL);
    var token = sharedPreferences.getString("token");
    Response res = await post(postsURL, headers: {'authorization': token});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      sharedPreferences.setString(
          'notificationSubscription', subscriptionState.toString());
      setState(() {});
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

  SharedPreferences prefs;
  /* String _checkUserName = ""; */
  String _checkUserEmail = "";
  String _checkUserProfile = "";
  /* String _checkUserId = ""; */
  String tenant = Constants.tenant;
  String _totalCount = "";

  Future<Null> _getEmail() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString("token") != null) {
//          print('woo');
        _checkUser = true;
      }
      _checkUserName = prefs.getString("name");
      _checkUserEmail = prefs.getString("email");
      _checkUserProfile = prefs.getString("profile_url");
//      _checkUserId = prefs.getString("userIDPre");
    });
  }

  List<bool> loaders = [true];
  List<JobListHolder> models = [];
  List<JobListHolder> modelsInit = [];
  List<Shifts> modelShifts = [];
  List<Shifts> modelShiftHolder = [];
  List<Notiification> modelsNotification = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 =
      new GlobalKey<RefreshIndicatorState>();

  checkStorage([apiCall]) async {
    var availableShiftsStorage =
        await JsonStorage('availableShifts').readFile();
    List<JobListHolder> response = [];
    if (availableShiftsStorage == 'no file') {
      HttpRequests().getAvailableShifts().then((shifts) {
        setState(() {
          models = shifts;
          if (models.length == 0) {
            _isVisible = !_isVisible;
          }
          loaders = [];
          for (var i = 0; models.length > i; i++) {
            loaders.add(false); 
          }
          print('loaders $loaders');
        });
      });
    } else {
      Map<String, dynamic> dataHolder =
          json.decode(availableShiftsStorage)['data']['campaigns'];
      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder.values.toList()[j];
          var dataSort = dataHolder.values.toList();
          /* dataSort.sort((a, b) {
              var adate = a['start']; //before -> var adate = a.expiry;
              var bdate = b['start']; //before -> var bdate = b.expiry;
              return adate.compareTo(
                  bdate); //to get the order other way just switch `adate & bdate`
            }); */
          print('holder');
          print(dataHolder);
          JobListHolder models = JobListHolder.fromJson(dataSort[j]);
          var data = dataHolder.values.toList()[j];

          response.add(models);
        }
        setState(() {
          models = response;
          if (models.length == 0) {
            _isVisible = false;
          }
          loaders = [];
          for (var i = 0; models.length > i; i++) {
            loaders.add(false); 
          }
          print('loaders $loaders');
        });

        List jobs = [];
        for (var count = 0; count < models.length; count++) {
          if (jobs.contains(models[count].job_type)) {
            continue;
          } else {
            jobs.add(models[count].job_type);
          }
        }
        setState(() {
          jobTypes = jobs;
          jobTypes.sort();
        });
        /* print(models[0].job_type);   */
        print(models);
        if (apiCall == null) {
          HttpRequests().getAvailableShifts().then((shifts) {
            setState(() {
              models = shifts;
              if (models.length == 0) {
                _isVisible = !_isVisible;
              }
              loaders = [];
              for (var i = 0; models.length > i; i++) {
                loaders.add(false); 
              }
              print('loaders $loaders');
            });
          });
        }
        return models;
      }
    }        
  }

  declineReasonsBuild(position) {
    List<Widget> reasons = List();
    bool selected = false;    
    declineReasonsList.asMap().forEach((index, item) {
      reasons.add(Container(    
        /* decoration:
          BoxDecoration( 
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20.0
              )
            ],
            borderRadius:
              BorderRadius.circular(10.0),                                                                                    
        ),    */                                   
        padding: EdgeInsets.only(right: 5.0,),

        child: ChoiceChip(
          elevation: 2.0,

          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)),),
          label: Text(declineReasonsList[index], style: TextStyle(fontSize: 13, fontFamily: 'Gotik'),),
          selectedColor: hexToColor(global.brand_color_secondary_action),
          selected: selected,
          onSelected: (selectedValue) async {
            print(declineReasonsList[index]);
            List<int> declineShifts = [];
            for (var shift in models[position].shifts) {
              declineShifts.add(shift.id);                                                                                    
            } 
            prefs = await SharedPreferences.getInstance();
              await HttpRequests().declineShifts(declineShifts, declineReasonsList[index]).then((message) {
                prefs.setString('firstNotInterested','true');
                showToast(message);     
                setState(() {
                  loaders[index] = false;
                  print(loaders);
                  declineReason = null;
                });                                                                               
              });                
              checkStorage();                                                
          },
        ),
  ));
      
    });
    return reasons;
  }

  getPosts() async {
    final String postsURL =
        "http://ondemandstaffing.app/api/v1/shifts/view_all_jobs/?tenant=" +
            tenant;
    List<JobListHolder> response = [];
    List<JobListHolder> dataSortJobType = [];
    List<Shifts> responseShift = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
//    print(token);
    Response res = await get(postsURL,
        headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
      print(responseJson);

//      Map<String, dynamic> dataHolderList = responseJson['data']['campaigns'] ;

      Map<String, dynamic> dataHolder = responseJson['data']['campaigns'];

      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder.values.toList()[j];
          var dataSort = dataHolder.values.toList();

          JobListHolder models = JobListHolder.fromJson(dataSort[j]);
          response.add(models);
          /* dataSortJobType = response.where((i) => i.job_type == 'IV Antibiotic Therapy').toList();

          print(dataSortJobType); */
        }
      }
    }
    modelsInit = response;
    setState(() {
      models = response;
      if (models.length == 0) {
        _isVisible = !_isVisible;
      }
    });

    List jobs = [];
    for (var count = 0; count < models.length; count++) {
      if (jobs.contains(models[count].job_type)) {
        continue;
      } else {
        jobs.add(models[count].job_type);
      }
    }
    setState(() {
      jobTypes = jobs;
      jobTypes.sort();
    });
    print('modelos');
    /* print(models[0].job_type);   */
    print(jobTypes);
    return models;
  }

  List jobTypes;
  var _jobFilterType = null;

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

  getNotifications() async {
    if (GlobalData().notificationsAmount != null) {
      _totalCount = GlobalData().notificationsAmount.toString();
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _checkUserId = sharedPreferences.getString("userID");
    List<Notiification> responseNotification = [];
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
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          Notiification models = Notiification.fromJson(dataJob);
          /* if (models.content_type == 'new_notification' ||  models.content_type == 'notification'){
            GlobalData().notificationsAmount = dataHolder.length;
            setState(() {
              _totalCount = dataHolder.length.toString();
            }); 
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

  Widget gridViewWidget() {
    if (models.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }    
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        await HttpRequests().getAvailableShifts().then((shifts) {
          setState(() {
            models = shifts;
            if (models.length == 0) {
              _isVisible = !_isVisible;
            }
            loaders = [];
            for (var i = 0; models.length > i; i++) {
              loaders.add(false); 
            }
          });
        });
      },
      child: AnimatedSize(
        vsync: this,
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 300),
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            itemCount: models.length,          
            reverse: false,
//          gridDelegate:
//              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemBuilder: (context, position) {
//            MediaQueryData mediaQueryData = MediaQuery.of(context);
              /* print('tipos');
            print(models[position].job_type); */                    
            if (_jobFilterType == null && pickedDate == null) {            
              return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Material(
                        child: Container(                          
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
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(top: 5),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.58,
//                                       width: 300,
                                              child: Text(
                                                models[position].job_type,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: TextStyle(
                                                    letterSpacing: 0.0,
                                                    color: Colors.blueAccent,
                                                    fontFamily: "Sans",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20.0),
                                              ),
                                            ),
                                            Text(
                                              models[position].client_name,
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
                                              width: 45.0,
                                              padding: EdgeInsets.only(right: 0),
                                              margin: EdgeInsets.only(top: 0),
                                              height: 45.0,
                                              decoration: new BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  image: new DecorationImage(
                                                      fit: BoxFit.contain,
                                                      image: new NetworkImage(
                                                          models[position]
                                                              .banner_image)))),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: <Widget>[
                                        Text(
                                            '${global.default_currency_symbol + double.parse(models[position].pay_rate).toStringAsFixed(2)}/hr',
//                                global.default_currency_three_code,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontFamily: "Sans",
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ],
                                    ),

                                    Row(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: 30.0, bottom: 50.0)),
                                        Expanded(
                                          child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                    MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 2),
                                                      child: Text(
                                                        'Location:',
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            color: Colors.black54,
                                                            letterSpacing: 0.3,
                                                            wordSpacing: 0.5),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                          CupertinoPageRoute<
                                                                  void>(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  MapShiftPage(models[
                                                                      position])));

//                                            Navigator.pushReplacement(
//                                                context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                                    },
                                                    child: (Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.75,
                                                        padding: EdgeInsets.only(
                                                            left: 2),
                                                        child: Text(
                                                          models[position]
                                                              .shifts[0]
                                                              .address,
                                                          style: TextStyle(
                                                              fontFamily: "Gotik",
                                                              color:
                                                                  Colors.black54,
                                                              letterSpacing: 0.2,
                                                              fontSize: 13.0,
                                                              wordSpacing: 0.0),
                                                        ),
                                                      ),
                                                    )),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          flex: 6,
                                        ),
                                      ],
                                    ),

                                    Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        for (var i in models[position].shifts)
//                                     Text(i.start),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 5.0, top: 5.0),
                                            child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.stretch,
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    width: 95,
                                                    /* date of shift */
                                                    child: Text(
                                                        formatter.format(
                                                            DateTime.parse(
                                                                i.start)),
                                                        style: TextStyle(
                                                            fontFamily: "Gotik",
                                                            color: Colors.black54,
                                                            letterSpacing: 0.3,
                                                            wordSpacing: 0.5)),
                                                  ),
                                                  flex: 2,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black12,
//                          border: Border.all(color: Colors.blueAccent),
                                                      borderRadius: BorderRadius
                                                          .only(
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                      5.0),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                      5.0),
                                                              topLeft:
                                                                  Radius.circular(
                                                                      5.0),
                                                              topRight: Radius
                                                                  .circular(5.0)),
//                          borderRadius: BorderRadius.only(Rad),
                                                    ),
                                                    padding: EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                                    height: 30,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        Container(
                                                          padding:
                                                              EdgeInsets.fromLTRB(
                                                                  5, 0, 5, 0),
                                                          margin:
                                                              EdgeInsets.fromLTRB(
                                                                  5, 0, 3, 0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
                                                                ),
                                                          ),
                                                          child: Text(
                                                              formatterTime.format(
                                                                  DateTime.parse(
                                                                      i.start)),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Gotik",
                                                                  color: Colors
                                                                      .black54,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  wordSpacing:
                                                                      0.5)),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.fromLTRB(
                                                                  0, 0, 10, 0),
//                                          margin: EdgeInsets.fromLTRB(10, 0, 15, 0),
//                                          decoration: BoxDecoration(
//                                            border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
//                                            ),
//                                          ),
                                                          child: Text('-',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Gotik",
                                                                  color: Colors
                                                                      .black54,
                                                                  letterSpacing:
                                                                      0.3,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  wordSpacing:
                                                                      0.5)),
                                                        ),
                                                        Text(
                                                            formatterTime.format(
                                                                DateTime.parse(
                                                                    i.end)),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Gotik",
                                                                color: Colors
                                                                    .black54,
                                                                letterSpacing:
                                                                    0.3,
                                                                wordSpacing:
                                                                    0.5)),
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

                                    /// Set Animation image to detailProduk layout
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                                child: Container(height: 1.0, color: Colors.black12,),
                              ),
                              AnimatedSize(
                                vsync: this,
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 300),
                                child: Container(                              
                                  /* height: 50.0, */
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  child: (loaders != [] && !loaders[position]) ?  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[                                    
                                      Expanded(                                      
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              loaders[position] = true;
                                              print(loaders);
                                            });
                                            /* This yes */
                                            /* var prefs = await SharedPreferences.getInstance();
                                            List<int> declineShifts = [];
                                            for (var shift in models[position].shifts) {
                                              declineShifts.add(shift.id);                                                                                    
                                            }                                        
                                            if (prefs.getString('firstNotInterested') != 'true') {
                                              _showNotInterestedAlertDialog(declineShifts, position);
                                            } else {
                                              _showNotInterestedOptionsDialog(declineShifts, position);
                                            } */

                                             /* This no */                                  
                                            /* await HttpRequests().declineShifts(declineShifts).then((message) {
                                              prefs.setString('firstNotInterested','true');
                                              showToast(message);     
                                              setState(() {
                                                loaders[position] = false;
                                                print(loaders);
                                              });                                                                               
                                            });
                                            checkStorage();   */                                      
                                          },
                                          child:
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                            child: Container(
                                              
                                              /* margin: EdgeInsets
                                                  .only(
                                                      top: 10), */
                                              height: 40.0,
                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                              /* width: 90.0, */
                                              child: Text(
                                                'Decline',
                                                textAlign: TextAlign.center,
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
                                                color: Colors.grey
                                                //                                               gradient: LinearGradient(
                                                //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                              ),
                                            ),
                                          )
                                           /* Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                            child: Container(
                                              height: 40.0,      
                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                              child: (loaders != [] && !loaders[position]) ? Text(
                                                'Decline',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(          
                                                    color: Colors.white,
                                                    height: 1.0,
                                                    letterSpacing: 0.2,
                                                    fontFamily: "Sans",
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w800),
                                              ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
                                              alignment: FractionalOffset.center,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
                                                borderRadius: BorderRadius.circular(30.0),
                                              )                                              
                                            )
                                          ) */
                                        )
                                      ),
                                      /* Container(height: 60.0, width: 1.0, color: Colors.black12,),                                     */
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(                                      
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return detailProduk(models[position]);
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                                            child: actionButton('View more')
                                          )
                                        )
                                      ),
                                    ],
                                  ) : Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            loaders[position] = false;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                                          height: 40.0,
                                          width: 40.0,
                                          decoration:
                                                  BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(spreadRadius: 0.0,
                                                      color: Colors
                                                          .black26,
                                                      blurRadius:
                                                          10.0),
                                                      

                                                ],
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            5.0),
                                                color: Colors.white
                                                //                                               gradient: LinearGradient(
                                                //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                              ),                                        
                                          child: Icon(Icons.close)
                                        )
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10.0),
                                          child: Wrap(
                                            /* alignment: WrapAlignment.center, */
                                            alignment: WrapAlignment.end,
                                            children: declineReasonsBuild(position)
                                          ),
                                        ),
                                      )                                
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
//      ),
                    );             
            } else if (_jobFilterType != null) {
              return models[position].job_type.contains(_jobFilterType) ?
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Material(
                  child: Container(                          
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
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 5),
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.58,
//                                       width: 300,
                                        child: Text(
                                          models[position].job_type,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                              letterSpacing: 0.0,
                                              color: Colors.blueAccent,
                                              fontFamily: "Sans",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20.0),
                                        ),
                                      ),
                                      Text(
                                        models[position].client_name,
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
                                        width: 45.0,
                                        padding: EdgeInsets.only(right: 0),
                                        margin: EdgeInsets.only(top: 0),
                                        height: 45.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                                fit: BoxFit.contain,
                                                image: new NetworkImage(
                                                    models[position]
                                                        .banner_image)))),
                                  ),
                                ],
                              ),

                              Row(
                                children: <Widget>[
                                  Text(
                                      '${global.default_currency_symbol + models[position].pay_rate}/hr',
//                                global.default_currency_three_code,
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontFamily: "Sans",
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),

                              Row(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.0, bottom: 50.0)),
                                  Expanded(
                                    child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 2),
                                                child: Text(
                                                  'Location:',
                                                  style: TextStyle(
                                                      fontFamily: "Gotik",
                                                      color: Colors.black54,
                                                      letterSpacing: 0.3,
                                                      wordSpacing: 0.5),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    CupertinoPageRoute<
                                                            void>(
                                                        builder: (BuildContext
                                                                context) =>
                                                            MapShiftPage(models[
                                                                position])));

//                                            Navigator.pushReplacement(
//                                                context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                              },
                                              child: (Align(
                                                alignment:
                                                    Alignment.centerLeft,
                                                child: Container(
                                                  width:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.75,
                                                  padding: EdgeInsets.only(
                                                      left: 2),
                                                  child: Text(
                                                    models[position]
                                                        .shifts[0]
                                                        .address,
                                                    style: TextStyle(
                                                        fontFamily: "Gotik",
                                                        color:
                                                            Colors.black54,
                                                        letterSpacing: 0.2,
                                                        fontSize: 13.0,
                                                        wordSpacing: 0.0),
                                                  ),
                                                ),
                                              )),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    flex: 6,
                                  ),
                                ],
                              ),

                              Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  for (var i in models[position].shifts)
//                                     Text(i.start),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 5.0, top: 5.0),
                                      child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.stretch,
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              width: 95,
                                              /* date of shift */
                                              child: Text(
                                                  formatter.format(
                                                      DateTime.parse(
                                                          i.start)),
                                                  style: TextStyle(
                                                      fontFamily: "Gotik",
                                                      color: Colors.black54,
                                                      letterSpacing: 0.3,
                                                      wordSpacing: 0.5)),
                                            ),
                                            flex: 2,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
//                          border: Border.all(color: Colors.blueAccent),
                                                borderRadius: BorderRadius
                                                    .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                5.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                5.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                5.0),
                                                        topRight: Radius
                                                            .circular(5.0)),
//                          borderRadius: BorderRadius.only(Rad),
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              height: 30,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                    margin:
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 3, 0),
                                                    decoration:
                                                        BoxDecoration(
                                                      border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
                                                          ),
                                                    ),
                                                    child: Text(
                                                        formatterTime.format(
                                                            DateTime.parse(
                                                                i.start)),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Gotik",
                                                            color: Colors
                                                                .black54,
                                                            letterSpacing:
                                                                0.3,
                                                            wordSpacing:
                                                                0.5)),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 10, 0),
//                                          margin: EdgeInsets.fromLTRB(10, 0, 15, 0),
//                                          decoration: BoxDecoration(
//                                            border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
//                                            ),
//                                          ),
                                                    child: Text('-',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Gotik",
                                                            color: Colors
                                                                .black54,
                                                            letterSpacing:
                                                                0.3,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800,
                                                            wordSpacing:
                                                                0.5)),
                                                  ),
                                                  Text(
                                                      formatterTime.format(
                                                          DateTime.parse(
                                                              i.end)),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Gotik",
                                                          color: Colors
                                                              .black54,
                                                          letterSpacing:
                                                              0.3,
                                                          wordSpacing:
                                                              0.5)),
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

                              /// Set Animation image to detailProduk layout
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                          child: Container(height: 1.0, color: Colors.black12,),
                        ),
                        AnimatedSize(
                          vsync: this,
                          curve: Curves.fastOutSlowIn,
                          duration: Duration(milliseconds: 300),
                          child: Container(                              
                            /* height: 50.0, */
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: (loaders != [] && !loaders[position]) ?  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[                                    
                                Expanded(                                      
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        loaders[position] = true;
                                        print(loaders);
                                      });
                                      /* This yes */
                                      /* var prefs = await SharedPreferences.getInstance();
                                      List<int> declineShifts = [];
                                      for (var shift in models[position].shifts) {
                                        declineShifts.add(shift.id);                                                                                    
                                      }                                        
                                      if (prefs.getString('firstNotInterested') != 'true') {
                                        _showNotInterestedAlertDialog(declineShifts, position);
                                      } else {
                                        _showNotInterestedOptionsDialog(declineShifts, position);
                                      } */

                                        /* This no */                                  
                                      /* await HttpRequests().declineShifts(declineShifts).then((message) {
                                        prefs.setString('firstNotInterested','true');
                                        showToast(message);     
                                        setState(() {
                                          loaders[position] = false;
                                          print(loaders);
                                        });                                                                               
                                      });
                                      checkStorage();   */                                      
                                    },
                                    child:
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                      child: Container(
                                        
                                        /* margin: EdgeInsets
                                            .only(
                                                top: 10), */
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        /* width: 90.0, */
                                        child: Text(
                                          'Decline',
                                          textAlign: TextAlign.center,
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
                                          color: Colors.grey
                                          //                                               gradient: LinearGradient(
                                          //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                        ),
                                      ),
                                    )
                                      /* Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                      child: Container(
                                        height: 40.0,      
                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        child: (loaders != [] && !loaders[position]) ? Text(
                                          'Decline',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(          
                                              color: Colors.white,
                                              height: 1.0,
                                              letterSpacing: 0.2,
                                              fontFamily: "Sans",
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w800),
                                        ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
                                          borderRadius: BorderRadius.circular(30.0),
                                        )                                              
                                      )
                                    ) */
                                  )
                                ),
                                /* Container(height: 60.0, width: 1.0, color: Colors.black12,),                                     */
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(                                      
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return detailProduk(models[position]);
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                                      child: actionButton('View more')
                                    )
                                  )
                                ),
                              ],
                            ) : Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      loaders[position] = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                                    height: 40.0,
                                    width: 40.0,
                                    decoration:
                                            BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(spreadRadius: 0.0,
                                                color: Colors
                                                    .black26,
                                                blurRadius:
                                                    10.0),
                                                

                                          ],
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      5.0),
                                          color: Colors.white
                                          //                                               gradient: LinearGradient(
                                          //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                        ),                                        
                                    child: Icon(Icons.close)
                                  )
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Wrap(
                                      /* alignment: WrapAlignment.center, */
                                      alignment: WrapAlignment.end,
                                      children: declineReasonsBuild(position)
                                    ),
                                  ),
                                )                                
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
//      ),
              ) : Container(height: 0.0);                
            } else if (pickedDate != null) {
              var shiftWithDate = [];            
              for (var shift in models[position].shifts) {
                if (formatter.format(DateTime.parse(shift.start)) == formatter.format(pickedDate)) {
                  shiftWithDate.add(formatter.format(DateTime.parse(shift.start)));
                }
              }
              /* setState(() {
                shiftsWithDate = shiftWithDate;
              });
              print(shiftsWithDate); */
              return shiftWithDate.length > 0 ?
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Material(
                  child: Container(                          
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
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(top: 5),
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.58,
//                                       width: 300,
                                        child: Text(
                                          models[position].job_type,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                              letterSpacing: 0.0,
                                              color: Colors.blueAccent,
                                              fontFamily: "Sans",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20.0),
                                        ),
                                      ),
                                      Text(
                                        models[position].client_name,
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
                                        width: 45.0,
                                        padding: EdgeInsets.only(right: 0),
                                        margin: EdgeInsets.only(top: 0),
                                        height: 45.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                                fit: BoxFit.contain,
                                                image: new NetworkImage(
                                                    models[position]
                                                        .banner_image)))),
                                  ),
                                ],
                              ),

                              Row(
                                children: <Widget>[
                                  Text(
                                      '${global.default_currency_symbol + models[position].pay_rate}/hr',
//                                global.default_currency_three_code,
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontFamily: "Sans",
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),

                              Row(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 30.0, bottom: 50.0)),
                                  Expanded(
                                    child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Align(
                                              alignment:
                                                  Alignment.centerLeft,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 2),
                                                child: Text(
                                                  'Location:',
                                                  style: TextStyle(
                                                      fontFamily: "Gotik",
                                                      color: Colors.black54,
                                                      letterSpacing: 0.3,
                                                      wordSpacing: 0.5),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    CupertinoPageRoute<
                                                            void>(
                                                        builder: (BuildContext
                                                                context) =>
                                                            MapShiftPage(models[
                                                                position])));

//                                            Navigator.pushReplacement(
//                                                context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                              },
                                              child: (Align(
                                                alignment:
                                                    Alignment.centerLeft,
                                                child: Container(
                                                  width:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.75,
                                                  padding: EdgeInsets.only(
                                                      left: 2),
                                                  child: Text(
                                                    models[position]
                                                        .shifts[0]
                                                        .address,
                                                    style: TextStyle(
                                                        fontFamily: "Gotik",
                                                        color:
                                                            Colors.black54,
                                                        letterSpacing: 0.2,
                                                        fontSize: 13.0,
                                                        wordSpacing: 0.0),
                                                  ),
                                                ),
                                              )),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    flex: 6,
                                  ),
                                ],
                              ),

                              Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  for (var i in models[position].shifts)
//                                     Text(i.start),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 5.0, top: 5.0),
                                      child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.stretch,
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              width: 95,
                                              /* date of shift */
                                              child: Text(
                                                  formatter.format(
                                                      DateTime.parse(
                                                          i.start)),
                                                  style: TextStyle(
                                                      fontFamily: "Gotik",
                                                      color: Colors.black54,
                                                      letterSpacing: 0.3,
                                                      wordSpacing: 0.5)),
                                            ),
                                            flex: 2,
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
//                          border: Border.all(color: Colors.blueAccent),
                                                borderRadius: BorderRadius
                                                    .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                5.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                5.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                5.0),
                                                        topRight: Radius
                                                            .circular(5.0)),
//                          borderRadius: BorderRadius.only(Rad),
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              height: 30,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 5, 0),
                                                    margin:
                                                        EdgeInsets.fromLTRB(
                                                            5, 0, 3, 0),
                                                    decoration:
                                                        BoxDecoration(
                                                      border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
                                                          ),
                                                    ),
                                                    child: Text(
                                                        formatterTime.format(
                                                            DateTime.parse(
                                                                i.start)),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Gotik",
                                                            color: Colors
                                                                .black54,
                                                            letterSpacing:
                                                                0.3,
                                                            wordSpacing:
                                                                0.5)),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 10, 0),
//                                          margin: EdgeInsets.fromLTRB(10, 0, 15, 0),
//                                          decoration: BoxDecoration(
//                                            border: Border(
//                                              right: BorderSide(width: 1.0, color: Colors.black12),
//                                              left: BorderSide(width: 1.0, color: Colors.black12),
//                                            ),
//                                          ),
                                                    child: Text('-',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Gotik",
                                                            color: Colors
                                                                .black54,
                                                            letterSpacing:
                                                                0.3,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800,
                                                            wordSpacing:
                                                                0.5)),
                                                  ),
                                                  Text(
                                                      formatterTime.format(
                                                          DateTime.parse(
                                                              i.end)),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Gotik",
                                                          color: Colors
                                                              .black54,
                                                          letterSpacing:
                                                              0.3,
                                                          wordSpacing:
                                                              0.5)),
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

                              /// Set Animation image to detailProduk layout
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                          child: Container(height: 1.0, color: Colors.black12,),
                        ),
                        AnimatedSize(
                          vsync: this,
                          curve: Curves.fastOutSlowIn,
                          duration: Duration(milliseconds: 300),
                          child: Container(                              
                            /* height: 50.0, */
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: (loaders != [] && !loaders[position]) ?  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[                                    
                                Expanded(                                      
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        loaders[position] = true;
                                        print(loaders);
                                      });
                                      /* This yes */
                                      /* var prefs = await SharedPreferences.getInstance();
                                      List<int> declineShifts = [];
                                      for (var shift in models[position].shifts) {
                                        declineShifts.add(shift.id);                                                                                    
                                      }                                        
                                      if (prefs.getString('firstNotInterested') != 'true') {
                                        _showNotInterestedAlertDialog(declineShifts, position);
                                      } else {
                                        _showNotInterestedOptionsDialog(declineShifts, position);
                                      } */

                                        /* This no */                                  
                                      /* await HttpRequests().declineShifts(declineShifts).then((message) {
                                        prefs.setString('firstNotInterested','true');
                                        showToast(message);     
                                        setState(() {
                                          loaders[position] = false;
                                          print(loaders);
                                        });                                                                               
                                      });
                                      checkStorage();   */                                      
                                    },
                                    child:
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                      child: Container(
                                        
                                        /* margin: EdgeInsets
                                            .only(
                                                top: 10), */
                                        height: 40.0,
                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        /* width: 90.0, */
                                        child: Text(
                                          'Decline',
                                          textAlign: TextAlign.center,
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
                                          color: Colors.grey
                                          //                                               gradient: LinearGradient(
                                          //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                        ),
                                      ),
                                    )
                                      /* Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0,),
                                      child: Container(
                                        height: 40.0,      
                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        child: (loaders != [] && !loaders[position]) ? Text(
                                          'Decline',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(          
                                              color: Colors.white,
                                              height: 1.0,
                                              letterSpacing: 0.2,
                                              fontFamily: "Sans",
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w800),
                                        ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
                                          borderRadius: BorderRadius.circular(30.0),
                                        )                                              
                                      )
                                    ) */
                                  )
                                ),
                                /* Container(height: 60.0, width: 1.0, color: Colors.black12,),                                     */
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(                                      
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return detailProduk(models[position]);
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                                      child: actionButton('View more')
                                    )
                                  )
                                ),
                              ],
                            ) : Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      loaders[position] = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                                    height: 40.0,
                                    width: 40.0,
                                    decoration:
                                            BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(spreadRadius: 0.0,
                                                color: Colors
                                                    .black26,
                                                blurRadius:
                                                    10.0),
                                                

                                          ],
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      5.0),
                                          color: Colors.white
                                          //                                               gradient: LinearGradient(
                                          //                                                   colors: <Color>[Color(0xFF+global.), Color(0xFF536DFD)])
                                        ),                                        
                                    child: Icon(Icons.close)
                                  )
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Wrap(
                                      /* alignment: WrapAlignment.center, */
                                      alignment: WrapAlignment.end,
                                      children: declineReasonsBuild(position)
                                    ),
                                  ),
                                )                                
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
//      ),
              ) : Container(height: 0.0);                    
            }   
            }),
      ),
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

    Color hexToColor(String code) {
      Color color = code != null
          ? new Color(
              int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000)
          : Colors.white;
      return color;
    }

    /// Custom text header for bottomSheet
    final _fontCostumSheetBotomHeader = TextStyle(
        fontFamily: "Berlin",
        color: Colors.black54,
        fontWeight: FontWeight.w600,
        fontSize: 16.0);

    /// Custom text for bottomSheet
    final _fontCostumSheetBotom = TextStyle(
        fontFamily: "Sans",
        color: Colors.black45,
        fontWeight: FontWeight.w400,
        fontSize: 16.0);

    DateTimePickerTheme customTheme() {
      return DateTimePickerTheme(
        confirmTextStyle: TextStyle(
          color: Colors.lightBlue,
        ),
        itemTextStyle: TextStyle(
          color: Colors.black38,
        ),
      );
    }

    selectDate() {
      DatePicker.showDatePicker(
        context,
        onMonthChangeStartWithFirstDate: true,
        pickerTheme: customTheme(),
        minDateTime: DateTime.parse('2010-05-12'),
        maxDateTime: DateTime.parse('2021-11-25'),
        initialDateTime: DateTime.now(),
        dateFormat: datePickerFormat,
        onConfirm: (dateTime, List<int> index) {
          setState(() {
            pickedDate = dateTime;
            _jobFilterType = null;
            /* print(formatter.format(pickedDate)); */
          });
        },
      );
    }

    /// Create Modal BottomSheet (SortBy)
    void _modalBottomSheetSort() {
      showModalBottomSheet(
          context: context,
          builder: (builder) {
            return SingleChildScrollView(
              child: Theme(
                data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text(AppLocalizations.of(context).tr('sortBy'),
                          style: _fontCostumSheetBotomHeader),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Container(
                        width: 500.0,
                        color: Colors.black26,
                        height: 0.5,
                      ),
                      Padding(padding: EdgeInsets.only(top: 25.0)),
                      InkWell(
                          onTap: () {
                            models.sort((a, b) {
                              var dateA = a.shifts[0].start;
                              var dateB = b.shifts[0].start;
                              return dateA.compareTo(dateB);
                            });
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text(
                            /* AppLocalizations.of(context).tr('popularity') */ 'Date',
                            style: _fontCostumSheetBotom,
                          )),
                      Padding(padding: EdgeInsets.only(top: 25.0)),
                      /* InkWell(
                          onTap: () {                           
                            setState(() {
                              models = modelsInit; 
                              _jobFilterType = null;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            /* AppLocalizations.of(context).tr('popularity') */'Unsorted',
                            style: _fontCostumSheetBotom,
                          )),
                      Padding(padding: EdgeInsets.only(top: 25.0)), */
                      /* Text(
                        AppLocalizations.of(context).tr('new'),
                        style: _fontCostumSheetBotom,
                      ),
                      Padding(padding: EdgeInsets.only(top: 25.0)),
                      Text(
                        AppLocalizations.of(context).tr('discount'),
                        style: _fontCostumSheetBotom,
                      ),
                      Padding(padding: EdgeInsets.only(top: 25.0)),
                      Text(
                        AppLocalizations.of(context).tr('priceLow'),
                        style: _fontCostumSheetBotom,
                      ),
                      Padding(padding: EdgeInsets.only(top: 25.0)),
                      Text(
                        AppLocalizations.of(context).tr('priceHight'),
                        style: _fontCostumSheetBotom,
                      ),
                      Padding(padding: EdgeInsets.only(top: 25.0)), */
                    ],
                  ),
                )
              ),
            );
          });
    }

    void _modalType() {
      showModalBottomSheet(
          context: context,
          builder: (builder) {
            return jobTypes != null
                ? Theme(
                  data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
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
                    child: Column(
                      children: <Widget>[
                        Container(                          
                          /* height: 59.0, */
                          child: Column(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(top: 20.0)),
                              Text('JOB TYPES',
                                  style: _fontCostumSheetBotomHeader),
                              Padding(padding: EdgeInsets.only(top: 20.0)),
                              Container(
                                width: 500.0,
                                color: Colors.black26,
                                height: 0.5,
                              ),
                              /* Container(
                          width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[                          
                            Padding(padding: EdgeInsets.only(top: 12.5)),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                   _jobFilterType = null;                                 
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'All Types',
                                  style: _fontCostumSheetBotom,
                                )), 
                            Padding(padding: EdgeInsets.only(top: 12.5)),                    
                          ],
                        ),
                      ) */
                            ],
                          ),
                        ),
                        Expanded(
                            child: ListView.builder(
                          itemCount: jobTypes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(top: 12.5)),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _jobFilterType = jobTypes[index];
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text(
                                        jobTypes[index].toString(),
                                        style: _fontCostumSheetBotom,
                                      )),
                                  Padding(padding: EdgeInsets.only(top: 12.5)),
                                ],
                              ),
                            );
                          },
                        ))
                      ],
                    ),
                  ),
                )
                : CircularProgressIndicator();
          });
    }

    return EasyLocalizationProvider(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE4F0),
        appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
//          backgroundColor: const Color(0xFF488BEC),
          backgroundColor: hexToColor(global.brand_color_bg_light),
          centerTitle: true,
          elevation: 0.0,
          title: new Text(
            'Available Shifts',
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
//                    onTap: () {
//                      Navigator.of(context).push(PageRouteBuilder(
//                          pageBuilder: (_, __, ___) => new notification()));
//                    },
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
            Container(
              padding: EdgeInsets.only(top: 55),
              child: Visibility(
                  visible: _isVisible,
                  child: gridViewWidget(),
                  replacement: RefreshIndicator(
                    key: _refreshIndicatorKey2,
                    child: EmptyScreen(),
                    onRefresh: () async {
                      await HttpRequests().getAvailableShifts().then((shifts) {
                        setState(() {
                          models = shifts;
                          if (models.length == 0) {
                            _isVisible = !_isVisible;
                          }
                          loaders = [];
                          for (var i = 0; models.length > i; i++) {
                            loaders.add(false); 
                          }
                        });
                      });
                    },
                  )),
            ),

            Container(
              height: 50.9,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 1.0,
                      spreadRadius: 1.0),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    onTap: _modalBottomSheetSort,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.arrow_drop_down),
                        Padding(padding: EdgeInsets.only(right: 10.0)),
                        Text(
                          /* AppLocalizations.of(context).tr('sort'), */
                          ('Sort'),
                          style: _fontCostumSheetBotomHeader,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 45.9,
                        width: 1.0,
                        decoration: BoxDecoration(color: Colors.black12),
                      )
                    ],
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      accentColor: Colors.amber,
                    ),
                    child: InkWell(
                      onTap: selectDate,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            /* AppLocalizations.of(context).tr('sort'), */
                            ('Select Date'),
                            style: _fontCostumSheetBotomHeader,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 45.9,
                        width: 1.0,
                        decoration: BoxDecoration(color: Colors.black12),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: _modalType,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.arrow_drop_down),
                        Padding(padding: EdgeInsets.only(right: 0.0)),
                        Text(
                          /* AppLocalizations.of(context).tr('notification') */ 'Type',
                          style: _fontCostumSheetBotomHeader,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

//            AppbarGradient(),
          ],
        ),
      ),
    );
  }
}
