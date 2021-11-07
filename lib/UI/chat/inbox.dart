import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/emptyScreen.dart';
import 'package:wolf_jobs/UI/chat/messaging.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/model/Conversation.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';

class ChatInbox extends StatefulWidget {
  @override
  _ChatInboxState createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInbox> {

  String _totalCount = "";
  String _checkUserId = "";
  String tenant = Constants.tenant;
  List<Conversation> conversations = [];
  var formatterTime = new DateFormat('d MMMM kk:mm');   

  @override
  void initState() {
    // TODO: implement initState
    super.initState();      
    getNotifications();    
    /* getConversations(); */
    checkStorage();
    HttpRequests().getGlobalMessages();
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

  bool _isVisible = true;  
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  checkStorage() async {
    List<Conversation> responseList = [];
    var inboxStorage = await JsonStorage('inbox').readFile();    
    if (inboxStorage == 'no file') {
      HttpRequests().getInbox().then((response) {
        setState(() {
          conversations = response;
          inboxConversations();
          if (conversations.length == 0) {
            _isVisible = false;
          }
        });
      });
    } else {
      List<dynamic> dataHolder =
          json.decode(inboxStorage);
      if (dataHolder != null) {
        for (var i = 0; dataHolder.length > i; i++) {
          Conversation models = Conversation.fromJson(dataHolder[i]);          
          responseList.add(models);
        }   
        setState(() {
          conversations = responseList;
          inboxConversations();
          if (conversations.length == 0) {
            _isVisible = false;
          }
        });
                                
        HttpRequests().getInbox().then((response) {
          setState(() {
            conversations = response;
            inboxConversations();
            if (conversations.length == 0) {
            _isVisible = false;
          }
          });
        });        
      }
    }        
  }

  Widget inboxConversations() {
    if (conversations.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => ChatItem(chatKey: conversations[index].chat_key, name: conversations[index].name, profilePic: conversations[index].picture,)));
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(conversations[index].picture),
                  ),
                  title: Text(conversations[index].name, style: TextStyle(fontFamily: 'Gotik')),
                  subtitle: Text(conversations[index].last_message, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Gotik'),),
                  trailing: (conversations[index].unread_count != null && conversations[index].unread_count != '0.0') ? 
                    Container(
                      padding: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: hexToColor(global.brand_color_bg_light),
                        shape: BoxShape.circle
                      ),
                      child: Text(double.parse(conversations[index].unread_count).toInt().toString(), style: TextStyle(fontSize: 12.0),)
                    ) : 
                    Text(formatterTime.format(DateTime.parse(conversations[index].updated_at)), style:  TextStyle(color: Colors.grey, fontSize: 13.0, fontFamily: 'Gotik'))
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                ),
              ),
            ],
          );
        }
      ), 
      onRefresh: () async {
        await HttpRequests().getInbox().then((response) {
          setState(() {
            conversations = response;
            inboxConversations();
            if (conversations.length == 0) {
              _isVisible = false;
            }
          });
        }); 
      },
      key: _refreshIndicatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
//          backgroundColor: const Color(0xFF488BEC),
        backgroundColor: hexToColor(global.brand_color_bg_light),
        centerTitle: true,
        /* leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
          ), */
        elevation: 0.0,
        title: new Text(
          'Inbox',
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
      body: Visibility(
        visible: _isVisible,
        child: inboxConversations(),
        replacement: EmptyScreen(),
      ),
    );    
  }
}