import 'dart:convert';
import 'dart:io';

/* import 'package:geolocator/geolocator.dart'; */
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:wolf_jobs/Library/app-localizations.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/model/TimeSheet.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/material.dart';
/* import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart'; */
//import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:toast/toast.dart';
import 'package:toast/toast.dart';

class order extends StatefulWidget {
  @override
  _orderState createState() => _orderState();
}

class _orderState extends State<order> {

  var now = new DateTime.now();
  var formatter = new DateFormat('d MMMM y');  
  final hoursController = TextEditingController();
  bool _isVisible = true;  
  var index;

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  defineStatus(modelos) async {
      List status;
        for (var i = 0; modelos.length < i; i++) {
          status.add(modelos[i].pay_status);
        }
        print('status');
        print(status);
    }

  @override
  void initState() {
    // TODO: implement initState    
    /* getTimeSheets();  */     
    checkLastApiCall();
    trackSegment();
    super.initState();          
  }

  final String postsURLShifts =
      "http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/";
  

  List<TimeSheet> models = [];

  List<TimeSheet> filterModels = [];

  var timeInController;
  var timeOutController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  
  trackSegment() {
    Segment.track(
      eventName: 'View Timesheets',
      properties: {
        'Source': 'Native apps'
      }
    );
  }

  checkLastApiCall() async {
    var lastCallFile = await JsonStorage('lastTimesheetsCall').readFile();
    DateTime now = DateTime.now();
    /* print(now.difference(DateTime.parse('2020-06-02 00:15:50.049789')).inMinutes); */
    if (lastCallFile == 'no file') {
      checkStorage();      
      await JsonStorage('lastTimesheetsCall').writeFile(now.toString());
    } else {      
      if (now.difference(DateTime.parse(lastCallFile)).inMinutes > 4) {
        await JsonStorage('lastTimesheetsCall').writeFile(now.toString());
        print(now.difference(DateTime.parse(lastCallFile)).inMinutes);
        checkStorage();       
      } else {
        checkStorage(true);                
      }
    }
  }

  differenceInDays(models) {
    for(var model in models) {
      List<TimeSheet> filterResponse = [];
      DateTime dateTimeCreatedAt =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(model.created_at, true);          
      DateTime dateTimeNow = DateTime.now();
      final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inHours;     
      if (differenceInDays <= 48){          
        filterResponse.add(model);          
      }   
      setState(() {
        filterModels = filterResponse;      
      });
    }
  }

  checkStorage([apiCall]) async {    
    var timesheetStorage = await JsonStorage('timeSheets').readFile();
    List<TimeSheet> response = [];
    List<TimeSheet> filterResponse = [];
    if (timesheetStorage == 'no file') {   
      HttpRequests().getTimeSheets().then((timesheets) {
        setState(() {
          models = timesheets;
          differenceInDays(models);    
          print(models.isEmpty);
          if (models.isEmpty) {
            _isVisible = false;
          }
        });        
      });   
    } else {
      var dataHolder = json.decode(timesheetStorage);
      if (dataHolder != null) {
        for (int j = 0; j < dataHolder.length; j++) {
          var dataJob = dataHolder[j];
          print(dataHolder.length);
          TimeSheet models = TimeSheet.fromJson(dataJob);          
          DateTime dateTimeCreatedAt =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(models.created_at, true/* models.created_at , true */);          
          DateTime dateTimeNow = DateTime.now();
          final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inHours;          
          response.add(models);
          if (differenceInDays <= 48){          
            filterResponse.add(models);          
          }          
        }
        setState(() {
            models = response;      
            models.sort((a, b) {
              var dateA = a.timein;
              var dateB = b.timein;
              return dateA.compareTo(dateB);        
            });                            
            filterModels = filterResponse;      
            index = models.length;
            print('last index');
            print(index);
            print(models.isEmpty);
            if (models.length == 0) {
              _isVisible = false;
            }
          });
          if (apiCall == null) {
            HttpRequests().getTimeSheets().then((timesheets) {      
              setState(() {
                models = timesheets;   
                differenceInDays(models);             
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


  /// Custom Text Header
  var _txtCustomHead = TextStyle(
    color: Colors.black54,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  /// Custom Text Detail
  var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  /// Create Big Circle for Data Order Not Success
  var _bigCircleNotYet = Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );

  var _bigCircleYellow = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
      ),
    ),
  );

  /// Create Circle for Data Order Success
  var _bigCircle = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 14.0,
        ),
      ),
    ),
  );

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

    static var _detailTextBold = TextStyle(
    fontFamily: "Gotik",
    color: Colors.black54,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    wordSpacing: 0.5);

  var _bigCircleRed = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.cancel,
          color: Colors.redAccent,
          size: 14.0,
        ),
      ),
    ),
  );

  /// Create Small Circle
  var _smallCircle = Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      height: 3.0,
      width: 3.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget getListTimeSheet(){
    var formatterTime = new DateFormat('kk:mm:a');  
    List<String> status = List();
    for (var i = 0; models.length > i;i++) {      
      if (models[i].pay_status == 'paid') {
        status.add('Paid');
      } else if (models[i].pay_status != 'paid' && models[i].hour_status == 'approved') {
        status.add('Payment in Process');
      } else if (models[i].hour_status != 'approved') {
        status.add('Pending approval');
      }

    }
    if (models.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
        child: CircularProgressIndicator(),
      ),);
    } 
    return ListView.builder(           
      itemCount: models.length,
      shrinkWrap: true,
      reverse: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context,position){
        void _bottomSheet([color, title, jobType, date, startTime, endTime, totalHours, payRate, totalPay]) {
          showModalBottomSheet(
              context: context,
              builder: (builder) {
                return SingleChildScrollView(
                  child: Container(
                    color: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[                              
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.0)
      ,                                child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(right: 10.0, top: 0.0),
                                            child: color,
                                          ),
                                          Padding(padding: EdgeInsets.only(top: 25.0, bottom: 20.0)),
                                            Center(
                                                child: Text(
                                              title,
                                              style: _subHeaderCustomStyle,
                                            )),
                                        ],
                                      ), 
                                    ),                             
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      child: Text(jobType, style: _subHeaderCustomStyle),
                                    ),
                                    Icon(
                                      Icons.today
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.0)
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(height: 90, child: VerticalDivider(color: Colors.black, thickness: 2.0,)),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            date != null ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, bottom: 10.0, left: 10.0),
                                              child: Text(date, style: _detailTextBold),
                                            ) : Container(height: 0.0,),
                                            startTime != null ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, bottom: 10.0, left: 10.0),
                                              child: Text('Start time: ' + formatterTime.format(DateFormat("yyyy-MM-dd HH:mm").parse(startTime)), style: _detailText),
                                            ) : Container(height: 0.0,),
                                            endTime != null ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, bottom: 10.0, left: 10.0),
                                              child: Text('End time: ' + formatterTime.format(DateFormat("yyyy-MM-dd HH:mm").parse(endTime)), style: _detailText),
                                            ) : Container(height: 0.0,),
                                            totalHours != null ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, bottom: 0.0, left: 10.0),
                                              child: Text('Total hours: '+ totalHours, style: _detailText),
                                            ) : Container(height: 0.0,),
                                          ]
                                        ) 
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.0)
                                    ),
                                    Icon(
                                      Icons.attach_money,),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.0)
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[    
                                        Container(height: 50, child: VerticalDivider(color: Colors.black, thickness: 2.0,)),                                    
                                      Column(       
                                        crossAxisAlignment: CrossAxisAlignment.start,                                   
                                        children: <Widget>[                                            
                                          payRate != null ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0, bottom: 10.0, left: 10.0),
                                            child: Text('Pay rate: '+ global.default_currency_symbol + payRate, style: _detailText),
                                            ) : Container(height: 0.0,),
                                            totalPay != null ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, bottom: 0.0, left: 10.0),
                                              child: Text('Total pay: '+ global.default_currency_symbol + totalPay, style: _detailText),
                                            ) : Container(height: 0.0,),
                                        ],
                                      )
                                    ],)
                                    /* Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        'Specifications',
                                        style: TextStyle(
                                            fontFamily: "Gotik",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color: Colors.black,
                                            letterSpacing: 0.3,
                                            wordSpacing: 0.5),
                                      ),
                                    ), */                              
                                  ],
                                ),
                      ),
                    ),
                  ),
                );
              });
        }
        
        if (models[position].pay_status == 'pending') {
          
        } 
        var date = models[position].timein != null ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(models[position].timein , true) : null;          
        return GestureDetector(
          onTap: () {
            _bottomSheet(
              models[position].pay_status == 'paid' ? _bigCircle :
                    models[position].hour_status == 'approved' ? _bigCircleNotYet :
                    models[position].hour_status == null  ? _bigCircleYellow : _bigCircleRed,
              status[position],
              models[position].job_type,
              formatter.format(DateTime.parse(date.toString())).toString(),
              models[position].start,
              models[position].end,
              models[position].hours,
              (double.parse(models[position].total_pay) / double.parse(models[position].hours)).toStringAsFixed(1),
              models[position].total_pay,
            );
            /* showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                    color: models[position].pay_status == 'paid' ? Colors.lightGreen :
                      models[position].hour_status == 'approved' ? Colors.lightGreen :
                      models[position].hour_status == null  ? Colors.orangeAccent : Colors.redAccent,
                    title: status[position],
                    jobType: models[position].job_type,
                    date: formatter.format(DateTime.parse(date.toString())).toString(),
                    startTime: models[position].start,
                    endTime: models[position].end,
                    totalHours: models[position].hours,
                    payRate: (double.parse(models[position].total_pay) / double.parse(models[position].hours)).toStringAsFixed(1),
                    totalPay: models[position].total_pay,                      
                    buttonText: "Okay",
                  ),
            ) */

            ;
          },
          child: Container(
            color: Colors.white,
//                          height: 200,
            child:Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Column(
                  children: <Widget>[
                    models[position].pay_status == 'paid' ? _bigCircle :
                    models[position].hour_status == 'approved' ? _bigCircleNotYet :
                    models[position].hour_status == null  ? _bigCircleYellow : _bigCircleRed ,
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    qeueuItem(
                      txtHeader:  date == null ? 'Time in on null' : formatter.format(DateTime.parse(date.toString())) ,
                      txtInfo:  models[position].hours != null && models[position].job_type != null ? models[position].job_type + '\n' '${double.parse(models[position].hours).toStringAsFixed(2)} / hr' : 'Shift',
                      time: models[position].total_pay !=null ?  global.default_currency_symbol + models[position].total_pay : '',
                      paddingValue: 55.0,
                    ),
                    Padding(padding: EdgeInsets.only(top:40.0)),
//
                  ],
                ),
              ],
            ), /////
          )
        );
      }           
  );                    

  }  

  


  @override
  Widget build(BuildContext context) {    
    var data = EasyLocalizationProvider.of(context).data;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        drawer: MainMenu(),
        appBar: AppBar(          
          title: Text(
            /* AppLocalizations.of(context).tr('Timesheets'), */'Timesheets',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1.0,
        ),
        body: RefreshIndicator(
          child: SingleChildScrollView(
            child: Container(            
              padding: EdgeInsets.only(top:0),
              color: Colors.white,
  //            width: 800.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 25.0,right: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: double.infinity ,
  //                    maxWidth: 280
                  ),
                  child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      itemCount: filterModels.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context,position){
                          hoursController.text = filterModels[position].hours;
                          return TimeSheetEl(onUpdate: () {
                            HttpRequests().getTimeSheets().then((timesheets) {
                              setState(() {
                                models = timesheets;
                                differenceInDays(models);    
                                print(models.isEmpty);
                                if (models.isEmpty) {
                                  _isVisible = false;
                                }
                              });        
                            });                            
                          } , position: position, filterModels: filterModels, timein: filterModels[position].timein, timeout: filterModels[position].timeout, /* checkStorage: checkStorage, */ key: UniqueKey());
                        }
                    ),
                  ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 30.0)),
                Text(
                  /* AppLocalizations.of(context).tr('Previous Timesheets') */'Previous Timesheets',
                  style: _txtCustom.copyWith(
                      color: Colors.black54,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600),
                ),              
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 20.0),
                  /* height: MediaQuery.of(context).size.height*.90, */
                  child: Stack(
                    children: <Widget>[
                      Visibility(
                          visible: _isVisible,
                          child: getListTimeSheet(),
                          replacement: EmptyScreen(),
                          /* Container(
                            height: MediaQuery.of(context).size.height * .8,
                            child: Center(                              
                              child: Container(
                                height: 80.0,
                                margin: EdgeInsets.only(bottom: 70.0),
                                child: Card(                                
                                  child: new ListTile(
                                    title: Center(
                                      child: new Text('No TimeSheets Available'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ) */
                      ),
                    ],
                  ),
                ),
                  ],
                ),
              ),
            ),
          ), 
          onRefresh: () async {            
            await checkStorage();  
          },
          key: _refreshIndicatorKey,
        ),
      ),
    );
  }


}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText, jobType, date, startTime, endTime, totalHours, payRate, totalPay;
  final Color color;
  final Image image;

  CustomDialog({
    this.title,
    this.description,
    this.buttonText,
    this.color,
    this.image,
    this.jobType,
    this.date,
    this.startTime,
    this.endTime,
    this.totalHours,
    this.payRate,
    this.totalPay
  });  

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Consts.padding),
      ),      
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }  

  

  dialogContent(BuildContext context) {    
  return Stack(
    children: <Widget>[      
      Container(        
        padding: EdgeInsets.only(
          top: 30.0,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        margin: EdgeInsets.only(top: 25.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(color: color, width: 4.0),
          borderRadius: BorderRadius.circular(Consts.padding),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,// To make the card compact
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0)
              ,child: Text(
                jobType,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              date,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ), 
            Text(
              'Start time: ' + startTime,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),  
            Text(
              'End time: '+ endTime,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),  
            Text(
              'Total hours: '+ totalHours,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ), 
            Text(
              'Pay rate: '+ payRate,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),     
            Text(
              'Total pay: '+ totalPay,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),                   
            SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
      Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: color,
            radius: Consts.avatarRadius,
          ),
        ),
    ],
  );
}
}

class Consts {
    Consts._();

    static const double padding = 16.0;
    static const double avatarRadius = 25.0;
  }

class TimeSheetEl extends StatefulWidget {
  final position;
  final filterModels;  
  final timein;
  final timeout;
  /* final checkStorage; */
  final VoidCallback onUpdate;
  

  TimeSheetEl({Key key, @required this.position, this.onUpdate, @required this.filterModels, @required this.timein, @required this.timeout, /* @required this.checkStorage */}) : super(key: key);
  
  @override
  _TimeSheetElState createState() => _TimeSheetElState();
}

class _TimeSheetElState extends State<TimeSheetEl> {    
  dynamic timeInController = TextEditingController();
  dynamic timeOutController = TextEditingController();  
  var formatterString = new DateFormat('yMMMMd');
  var formatterTime = new DateFormat('kk:mm:a');  

  formatCheckInOut() {
    var dateFilterTime =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.timein , true);

    var dateTimeHolder = formatterTime.format(
        DateTime.parse(
            dateFilterTime.toString()));

    var dateFilter =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.timein , true);
      var  dataString =  formatterString.format(DateTime.parse(dateFilter.toString()));
      timeInController.text = dataString.toString() + ' ' + dateTimeHolder.toString();                    

      if (widget.timeout !=null){

        var dateFilterTimeOut =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.timeout  , true);


        var dateTimeOutHolder = formatterTime.format(DateTime.parse(
                dateFilterTimeOut.toString()));

      var  dataStringTimeOut =  formatterString.format(DateTime.parse(dateFilterTimeOut.toString()));
      timeOutController.text = dataStringTimeOut.toString()  + ' ' + dateTimeOutHolder.toString();




      }
  }

  @override
  void initState() {    
    formatCheckInOut();    
    super.initState();
    /* timeInController.text = widget.timein;
    timeOutController.text = widget.timeout; */    
  }

  bool isLoading = false; 

  var _txtCustomHead = TextStyle(
    color: Colors.black54,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  /// Custom Text Detail
  var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  /// Create Big Circle for Data Order Not Success
  var _bigCircleNotYet = Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );

  var _bigCircleYellow = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
      ),
    ),
  );

  /// Create Circle for Data Order Success
  var _bigCircle = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 14.0,
        ),
      ),
    ),
  );

  var _bigCircleRed = Padding(
    padding: const EdgeInsets.only(top: 2.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.cancel,
          color: Colors.redAccent,
          size: 14.0,
        ),
      ),
    ),
  );

  /// Create Small Circle
  var _smallCircle = Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      height: 3.0,
      width: 3.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );
  final String postsURLShifts =
      "http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/";

  shiftPosts(String id, String freelanerID, checkin, checkout) async {
    /* Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); */
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    setState(() {
      isLoading = true ;

    }); 

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
           
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");    
     Map<String, dynamic> dataIn;
     Map<String, dynamic> dataOut;
    if (_locationData != null){
        dataIn = {
          'message': 'check-in',
          'shifts': id,
          'tenant': Constants.tenant,
          /* 'timestamp': now.toString(), */
          'check_in_time': checkin,          
          'latitude': _locationData.latitude.toString(),
          'longitude': _locationData.longitude.toString(),
        };
        dataOut = {
          'message': 'check-out',
          'shifts': id,
          'tenant': Constants.tenant,
          /* 'timestamp': now.toString(), */
          'check_out_time': checkout,          
          'latitude': _locationData.latitude.toString(),
          'longitude': _locationData.longitude.toString(),
        };
      } else {
        dataIn = {
          'check_in_time': checkin,          
          'message': 'check-in',
          'shifts': id,
          'tenant': Constants.tenant,
          /* 'timestamp': now.toString(),   */      
        };
        dataOut = {
          'check_out_time': checkout,          
          'message': 'check-out',
          'shifts': id,
          'tenant': Constants.tenant,
          /* 'timestamp': now.toString(),   */      
        };
      }  
    var jsonResponse;
    Response res1 = await post(
      postsURLShifts,
      headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'/* HttpHeaders.authorizationHeader : token, 'Content-Type': 'application/json' */},
      body: jsonEncode(dataIn),
    );
    print('data in: $dataIn');
    print('data out: $dataOut');
    Response res2 = await post(
      postsURLShifts,
      headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'/* HttpHeaders.authorizationHeader : token, 'Content-Type': 'application/json' */},
      body: jsonEncode(dataOut),
    );

    if (res1.statusCode == 200 && res2.statusCode == 200) {

      setState(() {
        isLoading = false;

      });      
      var responseJson1 = jsonDecode(res1.body);
      print('responseJson1');
      print(responseJson1);
      var responseJson2 = jsonDecode(res2.body);
      print('responseJson1');
      print(responseJson2);

      showToast('You have updated your hours', duration: 4, gravity: Toast.BOTTOM);
      setState(() {
        print('ok good');
      });
    } else {
      var responseJson = jsonDecode(res1.body);
      showToast(responseJson["message"], duration: 4, gravity: Toast.BOTTOM);
    }
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override 
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(widget.position),
      padding: const EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.5,
                spreadRadius: 1.0,
              )
            ]),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
              const EdgeInsets.only(top: 20.0, left: 20.0, right: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                      widget.filterModels[widget.position].job_type !=null ? widget.filterModels[widget.position].job_type : '' ,
//                                        'sadsad',
                    style: _txtCustomHead.copyWith(
                        fontSize: 15.0, fontWeight: FontWeight.w600),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 5.0, left: 20.0, right: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Start Time',
                        style: _txtCustomSub,
                      ),
                      Container(                         
                        width: MediaQuery.of(context).size.width*.55,
                        height: 30.0,
                        child: TextFormField(      
                          maxLines: 1,                                                                        
                          style: new TextStyle(

                              fontSize: 13.0,
                              color: Colors.black
                          ),                        
                        controller: timeInController ,
                        decoration: InputDecoration(    
                          border: InputBorder.none,                                                                                                          
                          isDense: true,                                                                                            
                          suffixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 12.0),
                            child: Icon(Icons.create, size: 20.0,),
                          ),                

                            hintText: 'Start Time',
//                      hintStyle: TextStyle(color: Colors.black38,fontSize: 12),
                            hintStyle: TextStyle(
                                fontSize: 11.0,
                                fontFamily: 'Sans',
                                letterSpacing: 0.3,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600),
                            /* border: InputBorder.none, */


                            labelStyle: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'Sans',
                                letterSpacing: 0.3,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600)),
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          DatePicker.showTimePicker(
                            context,
                            showTitleActions: true,

                          onChanged: (date){
                            print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                          },
                          onConfirm: (date) {
                            print('confirm $date');
                            setState(() {
                                var _dateTime = date;
                                print(_dateTime);
                                String dateString =
                                new   DateFormat("MMMM dd, yyyy HH:mm:a").format(_dateTime);
                                timeInController.text = dateString;
                                print(dateString);                                                      
                              });
                          },
                              /* locale: LocaleType.en */
                          );
                        },
                        validator: (String value) {

                          if (value.trim().isEmpty) {
                            return "Please select TimeIn date ";
                          }
                        },
                      ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        child:  Text(
                        /* AppLocalizations.of(context).tr('Hours') */ 'Hours',
                          style: _txtCustomSub,
                        ),
                        fit: BoxFit.contain,
                      ),                                           
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child : Container(                                                  
                            child: Text(widget.filterModels[widget.position].hours != null ? (double.parse(widget.filterModels[widget.position].hours)).toStringAsFixed(2)  : '',
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                softWrap: true,
                              ),                                                
                          ),

                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                bottom: 30.0,
                left: 20.0,
                right: 17.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        /* AppLocalizations.of(context).tr('End Time') */'End Time',
                        style: _txtCustomSub,
                      ),
                      Container(
//                                                  height: 35,
//                                                height: 100,
                        width: MediaQuery.of(context).size.width*.55,
                        height: 30.0,
                        child: TextFormField(
                          maxLines: 1,      
                          style: new TextStyle(

                              fontSize: 13.0,
                              color: Colors.black
                          ),
                          controller: timeOutController ,
                          decoration: InputDecoration(
                            border: InputBorder.none,                            
                            isDense: true,                                                                                            
                            suffixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(start: 12.0),
                              child: Icon(Icons.create, size: 20.0,),
                            ), 
                              hintText: 'End Time',
//                      hintStyle: TextStyle(color: Colors.black38,fontSize: 12),
                              hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Sans',
                                  letterSpacing: 0.3,
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w600),                              


                              labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'Sans',
                                  letterSpacing: 0.3,
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w600)),
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode());

                            DatePicker.showTimePicker(
                                context,
                                showTitleActions: true,
//
                                onChanged: (date){
                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                },
                                onConfirm: (date) {
                                  print('confirm $date');
                                  setState(() {
                                    var _dateTime = date;
                                    print(_dateTime);
                                    String dateString =
                                    new   DateFormat("MMMM dd, yyyy HH:mm:a").format(_dateTime);
                                    timeOutController.text = dateString;
                                    print(dateString);
                                  });
                                },
                                /* locale: LocaleType.en */
                            );


                          },
                          validator: (String value) {

                            if (value.trim().isEmpty) {
                              return "Please select TimeOut Date";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        child: Text(
                        /* AppLocalizations.of(context).tr('Total Pay') */'Total Pay',
                          style: _txtCustomSub,
                        ),
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(widget.filterModels[widget.position].total_pay!=null ?  global.default_currency_symbol + widget.filterModels[widget.position].total_pay : ''),
                      ),
                    ],
                  )
                ],
              ),
            ),
            widget.filterModels[widget.position].hour_status != 'approved' ? InkWell(
              onTap: () async {                                                                  
                await shiftPosts(double.parse(widget.filterModels[widget.position].shift_id).toInt().toString(), double.parse(widget.filterModels[widget.position].freelancer_id).toInt().toString(), timeInController.text, timeOutController.text);                
                /* widget.onUpdate();    */ 
                /* await shiftPosts(double.parse(widget.filterModels[widget.position].shift_id).toInt().toString(), double.parse(widget.filterModels[widget.position].freelancer_id).toInt().toString(), 'check-out', timeInController.text, timeOutController.text);                             */
                widget.onUpdate();    
              },
              child:

              Container(
                  height: 50.0,
                  width: 1000.0,
                  color: Colors.blueGrey.withOpacity(0.1),
                  child:
                  isLoading == true ?
                  Center(
                    child: CircularProgressIndicator(),
                  )
                  :
                  Center(
                      child:
                      Text(/* AppLocalizations.of(context).tr('Update') */'Update',
                          style: _txtCustomHead.copyWith(
                              fontSize: 15.0, color: Colors.blueGrey)))


              ),
            ) : Container(height: 0.0,)
          ],
        ),
      ),
    );
  }
}

typedef UpdateCallback = void Function();

/// Constructor Data Orders
class qeueuItem extends StatelessWidget {
  @override
  static var _txtCustomOrder = TextStyle(
    color: Colors.black45,
    fontSize: 13.5,
    letterSpacing: 2,
//    wordSpacing: 4,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  String  txtInfo, time;
  var txtHeader;
  double paddingValue;

  qeueuItem(
      { this.txtHeader, this.txtInfo, this.time, this.paddingValue});

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 0.0,
                      top:2,
                    right: mediaQueryData.padding.right + paddingValue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(txtHeader, style: _txtCustomOrder),
                    Container(
                      width: MediaQuery.of(context).size.width*.4,
                      child: Text(
                        txtInfo,
                        style: _txtCustomOrder.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 11.0,
                            letterSpacing: 0,
                            color: Colors.black38),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0.0, -5.0, 0.0),

//                  alignment: Alignment(-1,-1),
                  child: Text(
                    time,
                    style: _txtCustomOrder..copyWith(fontWeight: FontWeight.w400),
                  ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
