import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/JobTypePreferences.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/customForms.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';

class AccountSettings extends StatefulWidget {
  AccountSettings({Key key}) : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {

  @override
  void initState() { 
    super.initState();
    getUserData();
    getNotifications();   
    trackSegment();
    getProfilePicCondition();
    getForms(); 
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        checkProfile = prefs.get("profile_url");        
      });
    });
  }
  
  String askForProfilePick;

  getProfilePicCondition() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("askForProfilePic") != null) {
        setState(() {
          askForProfilePick = prefs.getString("askForProfilePic");
        });
    } else {
      setState(() {
        askForProfilePick = 'true';
      });
    } 
  }

  String _totalCount = "";
  String _checkUserId = "";
  String tenant = Constants.tenant;
  String checkProfile;
  var _userName;  
  var _address;
  var _email;
  bool subscriptionState;  
  bool pageLoading; 
  List jsonForms;

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  trackSegment() {
    Segment.track(
        eventName: 'View Account Settings',
        properties: {'Source': 'Native apps'});
  }

  bool gotForms = false;

  getForms() async {
    setState(() {
      pageLoading = true;  
    });   
    await HttpRequests().getCustomJsonForms().then((forms) {
      setState(() {
        jsonForms = forms;
        gotForms = true;                         
      });
    });
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
    });
  }  

  Future getUserData() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {      
      _userName = prefs.getString("name");
      _address = prefs.getString("address");
      _email = prefs.getString("email");  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         backgroundColor: const Color(0xFFDDE4F0),
         appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          backgroundColor: hexToColor(global.brand_color_bg_light),
          centerTitle: true,
          elevation: 0.0,
          title: new Text(
            'Account Settings',
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
        body: Column(
          children: <Widget>[
            (jsonForms == null && !gotForms)  ?
            Container(height: 2.0, child: LinearProgressIndicator(backgroundColor: Color(0xFFDDE4F0), valueColor: AlwaysStoppedAnimation<Color>(hexToColor(global.brand_color_secondary_action)))) : Container(height: 2.0,),
            askForProfilePick == 'true' ?
            Container(
              margin: EdgeInsets.only(top: 15.0),
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200], width: 2.5),
                shape: BoxShape.circle,
              ),
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FancyShimmerImage(
                      boxFit: BoxFit.cover,
                      imageUrl: checkProfile != null
                          ? checkProfile
                          : 'https://i0.wp.com/www.dobitaobyte.com.br/wp-content/uploads/2016/02/no_image.png?ssl=1',
                      shimmerBaseColor: Colors.black38,
                      shimmerHighlightColor: Colors.white,
                      errorWidget:
                          Image.asset('assets/img/dummyProfilePic.png'),
                    ),
                  ),                  
                ],
              ),
            ) : Container(),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              child: Column(
                children: <Widget>[
                  _userName != null ? Text(_userName, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, fontFamily: 'Gotik',),) : Container(),
                  _email != null ? Text(_email, style: TextStyle(fontSize: 15.0, fontFamily: 'Gotik',/* fontWeight: FontWeight.w600 */),) : Container(),                  
                  _address != null ? Text(_address, style: TextStyle(fontSize: 15.0, fontFamily: 'Gotik',/* fontWeight: FontWeight.w600 */),) : Container(),                                    
                ],
              )
            ),
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0, bottom: 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => profil(isFromAccountSettings: true, isFromSignUp: false,)));
                        },
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[   
                              ListTile(                  
                                title: Text('Profile', style: TextStyle(fontFamily: 'Gotik',)),
                                subtitle: Text('Review and update your profile', style: TextStyle(fontFamily: 'Gotik',)),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => JobTypePreferences(true)));
                        },
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[   
                              ListTile(                  
                                title: Text('Job type preferences', style: TextStyle(fontFamily: 'Gotik',)),
                                subtitle: Text('Select job types you are interested in', style: TextStyle(fontFamily: 'Gotik',)),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                (jsonForms == null && gotForms == false) ?                 
                ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 0.0, right: 10.0, left: 10.0, bottom: 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => profil(isFromAccountSettings: true, isFromSignUp: false,)));
                        },
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[   
                              ListTile(                  
                                title: Container(width: 10.0, height: 10.0, color: Colors.grey, margin: EdgeInsets.only(right: 50.0),),
                                subtitle: Container(width: 200, height: 10.0, color: Colors.grey[400], margin: EdgeInsets.only(right: 10.0),),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),              
                  ],
                ) :
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,   
                  itemCount: jsonForms.length,           
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(top: 0.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => CustomForms(forms: jsonForms, index: index, isFromAccountSettings: true,)));
                        },
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[   
                              ListTile(                  
                                title: Text(jsonForms[index]['form_title'], style: TextStyle(fontFamily: 'Gotik',)),
                                subtitle: Text(jsonForms[index]['form_description'], style: TextStyle(fontFamily: 'Gotik',)),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
                  ],
                )
          ],
        ),
       ),
    );
  }
}