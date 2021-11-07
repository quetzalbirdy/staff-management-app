import 'dart:convert';

import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/MapShift.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:wolf_jobs/Library/carousel_pro/carousel_pro.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wolf_jobs/model/JobListHolder.dart';
import 'package:wolf_jobs/model/Shift.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class detailProduk extends StatefulWidget {
//  GridItem gridItem;
  final JobListHolder Joblistholder;

  detailProduk(this.Joblistholder);

  @override
  _detailProdukState createState() => _detailProdukState(Joblistholder);
}

/// Detail Product for Recomended Grid in home screen
class _detailProdukState extends State<detailProduk> {

  List<Marker> allMarkers = [];

  GoogleMapController _controller;

  double rating = 3.5;
  int starCount = 5;
  var now = new DateTime.now();
  var formatter = new DateFormat('MMMMd');
  var formatterTime = new DateFormat('kk:mm:a');

  /// Declaration List item HomeGridItemRe....dart Class
  final JobListHolder Joblistholder;

  _detailProdukState(this.Joblistholder);

  bool _isChecked = true;

  @override
  static BuildContext ctx;
  int valueItemChart = 0;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  List<Shifts> models = [];

  String tenant = Constants.tenant;

  void initState() {
    // TODO: implement initState
    super.initState();
    getShifts();
    insertIds();
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(widget.Joblistholder.shifts[0].latitude, widget.Joblistholder.shifts[0].longitude)));
  }

  List shiftIDs = [];
  String idList;

  insertIds() {
    for (var i in widget.Joblistholder.shifts) shiftIDs.add(i.id);

    getIds();
  }

  getIds() {
    setState(() {
      idList = shiftIDs.join(',');
//      print(idList);
    });
  }

  final String postsURL =
      "http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/";

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  shiftPosts() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final Map<String, dynamic> data = {
      'message': 'apply',
      'shifts': idList,
      'tenant': tenant
    };
//    print(data);
//    print(token);
    var jsonResponse;
    http.Response response = await http.post(
      postsURL,
      headers: {
        'Content-Type': 'application/json',
        'AUTHORIZATION': token,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
//      print(response.body);
      showToast("Request Sent", duration: 4, gravity: Toast.BOTTOM);
      Flushbar(
//        title:  responseJson['message'],
        message: 'Request Sent',
        duration: Duration(seconds: 3),
      )..show(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Menu()),
      );
    } else {
//      print(response.body);
      showToast(jsonResponse["message"], duration: 4, gravity: Toast.BOTTOM);
    }

    setState(() {});
  }

  getShifts() {
    var status = Joblistholder.shifts[0].status;
    for (int p = 0; p < Joblistholder.shifts.length; p++) {
//      print(Joblistholder.shifts[p].status);
      setState(() {
        models = Joblistholder.shifts;
      });
    }
  }

  List siftsId = [];

  /// BottomSheet for view more in specification
  void _bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  height: 1500.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Center(
                          child: Text(
                        'Description',
                        style: _subHeaderCustomStyle,
                      )),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                        child: Text(Joblistholder.notes, style: _detailText),
                      ),
                      Padding(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                        child: Text(
                          Joblistholder.client_name,
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
  }

  /// Custom Text black
  static var _customTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "Gotik",
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );

  /// Custom Text for Header title
  static var _subHeaderCustomStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);

  /// Custom Text for Detail title
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

  bool pressed = true;

  Widget build(BuildContext context) {
    /// Variable Component UI use in bottom layout "Top Rated Products"
    var _suggestedItem = Padding(
      padding: const EdgeInsets.only(
          left: 15.0, right: 20.0, top: 30.0, bottom: 20.0),
      child: Container(
        height: 280.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'TopRated',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gotik",
                      fontSize: 15.0),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'seeAll',
                    style: TextStyle(
                        color: Colors.indigoAccent.withOpacity(0.8),
                        fontFamily: "Gotik",
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
    _prevPage(BuildContext context) async {
      Navigator.push(

        context,
        MaterialPageRoute(builder: (context) => Menu()),
      );
    }
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,

//      child: WillPopScope(

//        key: new ValueKey("dismiss_key"),
//        direction: DismissDirection.startToEnd,
//        onDismissed: (direction){
//          if(direction == DismissDirection.startToEnd){
//            _prevPage(context);
//          }
//        },
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _key,
          appBar: AppBar(
            elevation: 0.5,
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(
              'Job Detail',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontSize: 17.0,
                fontFamily: "Gotik",
              ),
            ),
            actions: <Widget>[

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: InkWell(
                      onTap: () {

                      },
                      child: Stack(
                        alignment: AlignmentDirectional(-3.0, -3.0),
                        children: <Widget>[
                          Image.network(
                            widget.Joblistholder.banner_image,
                            height: 24.0,
                          ),

                        ],
                      ),

                    ),
                    padding: EdgeInsets.only(right: 15),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// Header image slider
                      Container(
                        height: 280.0,
                        child:GoogleMap(
                          initialCameraPosition:
                          CameraPosition(target: LatLng(widget.Joblistholder.shifts[0].latitude,  widget.Joblistholder.shifts[0].longitude), bearing: 15.0,
                              tilt: 12.0, zoom: 13.0),
                          markers: Set.from(allMarkers),
                          onMapCreated: mapCreated,
                        ),
//                        child: Hero(
//                          tag: "hero-grid-${widget.Joblistholder.id}",
//                          child: Material(
//                            child: new Carousel(
//                              dotColor: Colors.black26,
//                              dotIncreaseSize: 0,
//                              dotBgColor: Colors.transparent,
//                              autoplay: false,
//                              boxFit: BoxFit.fitWidth,
//                              images: [
//                                NetworkImage(widget.Joblistholder.banner_image),
////                              NetworkImage(widget.Joblistholder.banner_image),
////                              NetworkImage(widget.Joblistholder.banner_image),
//                              ],
//                            ),
//                          ),
//                        ),
                      ),

                      /// Background white title,price and ratting
                      Container(
                        decoration:
                        BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Color(0xFF656565).withOpacity(0.15),
                            blurRadius: 1.0,
                            spreadRadius: 0.2,
                          )
                        ]),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, top: 10.0, right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Container(
//                                        height: 30.0,
//                                        width: 75.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
//                                            Text(
//                                              widget.Joblistholder.rattingValue,
//                                              style:
//                                                  TextStyle(color: Colors.white),
//                                            ),
                                              Padding(
                                                  padding:
                                                  EdgeInsets.only(left: 8.0)),

                                              FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  widget.Joblistholder.title,
                                                  style: _customTextStyle,
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                  EdgeInsets.only(top: 5.0)),
                                              Text(
                                                Joblistholder.client_name,
                                                style: _detailText,
                                              ),
//                                            Icon(
//                                              Icons.star,
//                                              color: Colors.white,
//                                              size: 19.0,
//                                            ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 0.0),
                                      child: 
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              '\$${widget.Joblistholder.pay_rate}',
                                              style: _customTextStyle),
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      /// Background white for chose Size and Color

                      /// Background white for description
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: 600.0,
                          decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Color(0xFF656565).withOpacity(0.15),
                              blurRadius: 1.0,
                              spreadRadius: 0.2,
                            )
                          ]),
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: Text(
                                    'Description',
                                    style: _subHeaderCustomStyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0,
                                      right: 20.0,
                                      bottom: 10.0,
                                      left: 20.0),
                                  child: Text(widget.Joblistholder.notes,
                                      style: _detailText),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        _bottomSheet();
                                      },
                                      child: Text(
                                      'View More',
                                        style: TextStyle(
                                          color: Colors.indigoAccent,
                                          fontSize: 15.0,
                                          fontFamily: "Gotik",
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Background white for description
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: 600.0,
                          decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Color(0xFF656565).withOpacity(0.15),
                              blurRadius: 1.0,
                              spreadRadius: 0.2,
                            )
                          ]),
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Text(
                                      'Location of Job',
                                      style: _subHeaderCustomStyle,
                                    ),
                                  ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(CupertinoPageRoute<void>(
                                        builder: (BuildContext context) => MapShiftPage(widget.Joblistholder)
                                    ));

//                                            Navigator.pushReplacement(
//                                                context, MaterialPageRoute(builder: (context) => MyHomePage()));
                                  },
                                child:Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0,
                                        right: 20.0,
                                        bottom: 10.0,
                                        left: 20.0),
                                    child: Text(
                                        widget.Joblistholder.shifts[0].address,
                                        style: _detailText),
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Background white for Ratting
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          width: 600.0,
                          decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Color(0xFF656565).withOpacity(0.15),
                              blurRadius: 1.0,
                              spreadRadius: 0.2,
                            )
                          ]),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 20.0, left: 20.0, right: 20.0),
                            child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Shifts',
                                      style: _subHeaderCustomStyle,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 15.0, bottom: 15.0),
                                    )
                                  ],
                                ),
                                _shifts(),
                                Padding(padding: EdgeInsets.only(bottom: 0.0)),
                              ],
                            ),
                          ),
                        ),
                      ),

//                    _suggestedItem
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Container(
                  color: Colors.white70,
                  margin: EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      /// Button Pay
                      InkWell(
                        onTap: () {
                          setState(() {
                            pressed = !pressed;
                            shiftPosts();
                          });
                        },
                        child: Container(
                          height: 45.0,
//                        width: 200.0,
                          margin: EdgeInsets.only(bottom: 15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                          ),
                          child: Center(
                            child: Text(
                              pressed ? 'Request To Work' : 'Requesting',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
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
//      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  Widget _shifts() {
    if (models.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
//        child: Text('No Attachment found'),
      ));
    }

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
//      height: 300,
      child: Padding(
//      padding: const EdgeInsets.all(0.0),
        padding:
            EdgeInsets.only(left: 0.0, right: 10.0, top: 15.0, bottom: 0.0),
        child: ListView.builder(
            shrinkWrap: true,
//          reverse: true,

            itemCount: models.length,
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (context, position) {
              return Container(
                  padding: EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.black12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        child: Container(
                            margin: EdgeInsets.only(bottom: 0),
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
//                        color: Colors.black12,
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              topRight: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                            )),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                       Checkbox(
                                        value: models[position].isCheck,
                                        onChanged: (bool value) {
                                          setState(() {
                                            models[position].isCheck = value;
                                            if (models[position].isCheck == true) {
                                              shiftIDs.add(models[position].id);
                                              getIds();
                                            } else {
                                              shiftIDs.remove(models[position].id);
                                              getIds();
//                          }
                                            }
                                          });
                                        },
                                      ),
                                    Text(
                                    formatter.format(DateTime.parse(
                                        models[position].start)),
                                        style: TextStyle(
                                            fontFamily: "Gotik",
                                            color: Colors.black54,
                                            letterSpacing: 0.3,
                                            fontSize: 12,
                                            wordSpacing: 0.5),

                                    ),
                                    ],
                                  ),
                                  flex: 3,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(5.0),
                                          bottomRight: Radius.circular( 5.0),
                                          topLeft: Radius.circular(5.0),
                                          topRight: Radius.circular( 5.0)
                                      ),
//                          borderRadius: BorderRadius.only(Rad),
                                    ),

                                    padding: EdgeInsets.fromLTRB(0, 0, 0,0),
                                    height: 30,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.fromLTRB(5, 0, 0,0),
                                          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),

                                          child:Text( formatterTime.format(DateTime.parse(
                                              models[position].start)) , style: TextStyle(
                                              fontFamily: "Gotik",
                                              color: Colors.black54,
                                              letterSpacing: 0.3,
                                              fontSize: 12,
                                              wordSpacing: 0.5)),
                                        ),

                                        Container(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0,0),
//
                                          child:Text('-' , style: TextStyle(
                                              fontFamily: "Gotik",
                                              color: Colors.black54,
                                              letterSpacing: 0.3,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              wordSpacing: 0.5)),
                                        ),

                                        Text(formatterTime.format(DateTime.parse(
                                            models[position].end))   , style: TextStyle(
                                            fontFamily: "Gotik",
                                            color: Colors.black54,
                                            letterSpacing: 0.3,
                                            wordSpacing: 0.5)
                                        ),
                                      ],
                                    ),
                                  ),

                                  flex: 3,
                                ),
                              ],
                            )),
                      ),
                    ],
                  ));
            }),
      ),
    );
  }
}

Widget _line() {
  return Container(
    height: 0.9,
    width: double.infinity,
    color: Colors.black12,
  );
}
