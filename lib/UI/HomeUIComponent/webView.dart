import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class AppWebView extends StatefulWidget {  
  final url;
  AppWebView(this.url);

  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();    
    cargandoPagina = true;    
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
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

  String _totalCount = "";
  String _checkUserId = "";
  String tenant = Constants.tenant;
  bool cargandoPagina;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE4F0),
        appBar: new AppBar(
          iconTheme: new IconThemeData(color: Colors.white),
          backgroundColor: hexToColor(global.brand_color_bg_light),
          centerTitle: true,
          elevation: 0.0,
          title: new Text(   
            global.brand_name,         
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
        /* drawer: MainMenu(), */
        body: Stack(
          children: <Widget>[
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  cargandoPagina = false;                
                });
              },
            ),
            cargandoPagina == true ? Container(
              alignment: FractionalOffset.center,
              child: CircularProgressIndicator(),
            ) :
            Container(
              height: 0.0,
            ),
          ]
        )
    );
  }
}