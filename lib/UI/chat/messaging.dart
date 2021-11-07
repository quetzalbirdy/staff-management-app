import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wolf_jobs/Library/app-localizations.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/UI/chat/inbox.dart';
import 'package:wolf_jobs/model/Message.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:wolf_jobs/resources/pusher_service.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

class ChatItem extends StatefulWidget {
  final chatKey;
  final String name;
  final String profilePic;

  ChatItem({Key key, this.chatKey, this.name, this.profilePic}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> with TickerProviderStateMixin {
  List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;
  List<Message> messages = [];
  bool messagesUpToDate = false;
  bool sendingMessage = false;
  var currentUser;  

  PusherService pusherService = PusherService();
  StreamController<String> streamController = new StreamController.broadcast();

  @override
  void initState() {    
    super.initState();      
    getUserId();        
    checkStorage();  
    /* streamMessages(); */    
  }      

  streamMessages() async {   
    Stream stream = pusherService.eventStream;        
    pusherService.eventStream.listen((x) {
      _submitNewIncomingwMsg(json.decode(x)['message']);
    });
    /* streamController.stream.listen((message) {
      print('message');
      _submitNewMsg(message); 
    }); */
  }

  getUserId() async {
    var prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString("userID");
    print('${Constants.tenant}_u_${currentUser}_active');
    pusherService = PusherService();            
    pusherService.firePusher('${Constants.tenant}_u_${currentUser}_active', widget.chatKey); 
    setState(() {
      pusherService.eventStream.listen((x) {
        _submitNewIncomingwMsg(x);
      });
    });
  }

  deliveredTimeout() {
    /* setState(() {
      sendingMessage = false;
    }); */
    return new Timer(Duration(milliseconds: 4000), eraseDelivered); 
  }

  eraseDelivered() {
    setState(() {
      messagesUpToDate = false;
    });
  }

  bool _isVisible = true;

  checkStorage() async {
    List<Message> responseList = [];
    var conversationStorage = await JsonStorage('conversation${widget.chatKey}').readFile();    
    if (conversationStorage == 'no file') {
      HttpRequests().getMessages(widget.chatKey).then((response) {
        setState(() {
          messages = response;  
          messageList();
          if (messages.length == 0) {
            _isVisible = false;
          }                
          for (var message in messages) {
            _submitMsg(message);
          }
          sendingMessage = false;          
        });
      });
    } else {
      List<dynamic> dataHolder =
          json.decode(conversationStorage);
      if (dataHolder != null) {
        for (var i = 0; dataHolder.length > i; i++) {
          Message models = Message.fromJson(dataHolder[i]);          
          responseList.add(models);
        }  
        setState(() {
          messages = responseList;  
          messageList();
          if (messages.length == 0) {
            _isVisible = false;
          }                
          for (var message in messages) {
            _submitMsg(message);
          }
          sendingMessage = false;          
        });
                                
        HttpRequests().getMessages(widget.chatKey).then((response) {
          setState(() {
            messages = response;  
            messageList();
            if (messages.length == 0) {
              _isVisible = false;
            }   
            _messages = [];       
            for (var message in messages) {
              _submitMsg(message);
            }
            sendingMessage = false;          
            });
          });       
      }
    }        
  }  

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  Widget messageList() {
    if (messages.length == 0) {
      return Container(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }
    return ListView.builder(
      itemBuilder: (_, int index) => _messages[index],
      itemCount: _messages.length,
      reverse: true,
      padding: new EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
        var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
          data: data,
          child: Scaffold(
        appBar: AppBar(          
          elevation: 0.4,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {        
              HttpRequests().getMessages(widget.chatKey);      
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatInbox()));
            },
          ),

          title: Container(            
            child: Row(              
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePic),
                  ),
                ),
                Text(
                  widget.name,
                  style: TextStyle(
                      fontFamily: "Gotik", fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
          ),
          iconTheme: IconThemeData(color: Color(0xFF6991C7)),
          centerTitle: true,
          backgroundColor: hexToColor(global.brand_color_bg_light),
        ),        

        /// body in chat like a list in a message
        body: Container(
          color: Colors.white,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[            
            new Flexible(
              child: _messages.length>0
                  ?  Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: messageList()
                    ): Center(child: CircularProgressIndicator(),),
            ),                        
            /// Line
            new Divider(height: 1),
            Column(
              children: <Widget>[
                new Container(              
                  child: _buildComposer(),
                  decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(blurRadius: 1.0, color: Colors.black12)]),
                ),
                /* StreamBuilder(
                  stream: pusherService.eventStream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    /* _submitNewMsg(json.decode(snapshot.data)['message']); */
                    return Container(
                      child: Text(json.decode(snapshot.data)['message']),
                    );
                  },
                ), */
              ],
            ),
          ]),
        ),
      ),
    );
  }

  /// Component for typing text
  Widget _buildComposer() {
    return Container(
      child: new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.only(left: 5.0),
            child: new Row(
              children: <Widget>[
                /* Icon(Icons.add,color: Colors.blueAccent,size: 27.0,), */
                new Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new TextField(
                          controller: _textController,
                          onChanged: (String txt,) {
                            setState(() {
                              _isWriting = txt.length > 0;
                              messagesUpToDate = false;
                            });
                          },
                          onSubmitted: _submitNewMsg,
                          decoration: new InputDecoration.collapsed(
                              hintText: AppLocalizations.of(context).tr('hintChat'),
                              hintStyle: TextStyle(
                                  fontFamily: "Sans",
                                  fontSize: 16.0,
                                  color: Colors.black26)),
                        ),
                      ),
                    ),
                  ),
                ),
                new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 3.0),
                    child: /* Theme.of(context).platform == TargetPlatform.iOS
                        ? new CupertinoButton(
                        child: new Text("Submit"),
                        onPressed: _isWriting
                            ? () { 
                              var messageContent = _textController.text;
                              _submitNewMsg(_textController.text);
                              setState(() {
                                sendingMessage = true;
                              });
                              HttpRequests().sendMessage(widget.chatKey, messageContent).then((response) {                              
                                print(response);
                                if (response != '"Enqueued"') {
                                  setState(() {
                                    _messages.removeLast();
                                    sendingMessage = false;
                                  });
                                } else if (response == '"Enqueued"') {
                                  getMessages();     
                                  setState(() {
                                    messagesUpToDate = true;  
                                    sendingMessage = false;                                                                 
                                  });
                                  deliveredTimeout();                                                           
                                }
                              });
                            }
                            : null)
                        :  */new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: _isWriting
                          ?  () { 
                              var messageContent = _textController.text;
                              _submitNewMsg(_textController.text/* , false */);
                              setState(() {
                                sendingMessage = true;
                              });
                              HttpRequests().sendMessage(widget.chatKey, messageContent).then((response) {                              
                                print(response);
                                /* if (response != '"Enqueued"') {
                                  setState(() {
                                    _messages.removeLast();
                                    sendingMessage = false;
                                  });
                                } else if (response == '"Enqueued"') {
                                  getMessages();     
                                  setState(() {
                                    messagesUpToDate = true;                                                                                                   
                                  });
                                  deliveredTimeout();                                                           
                                } */
                              });
                            }
                          : null,
                    )),
              ],
            ),
            decoration: Theme.of(context).platform == TargetPlatform.iOS
                ? new BoxDecoration(
                    border: new Border(top: new BorderSide(color: Colors.brown)))
                : null),
      ),
    );
  }

  void _submitNewMsg(String txt/* ,bool isOtherUserMessage */) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(      
      txt: txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      isOtherUserMessage: true,
      /* createdAt: DateTime.now(),  */     
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  void _submitNewIncomingwMsg(String txt/* ,bool isOtherUserMessage */) {
    /* _textController.clear(); */
    /* setState(() {
      _isWriting = false;
    }); */
    Msg msg = new Msg(      
      txt: json.decode(txt)['message'],
      pic: json.decode(txt)['picture'],
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      isOtherUserMessage: false,
      /* createdAt: DateTime.now(),  */     
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  void _submitMsg(Message message) async {      
    var prefs = await SharedPreferences.getInstance();
    var currentUser = prefs.getString("userID");
    Msg msg = new Msg(      
      txt: message.body,
      /* pic: json.decode(txt)['picture'], */
      animationController: new AnimationController(

          vsync: this, duration: new Duration(milliseconds: 0)),
      createdAt: DateTime.parse(message.created_at),
      senderId: int.parse(message.sender_id),
      currentUser: int.parse(currentUser),
      senderUser: int.parse(message.sender_id),     
      isOtherUserMessage: true,       
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    pusherService.unbindEvent('create');
    super.dispose();
  }
}

class Msg extends StatelessWidget {
  Msg({this.txt, this.senderId, this.pic, this.isOtherUserMessage, this.createdAt, this.animationController, this.currentUser, this.senderUser, this.last, this.imagePath});

  final String txt;
  final AnimationController animationController;
  final int senderId;
  final DateTime createdAt;  
  final int currentUser;
  final int senderUser; 
  final bool last;
  final String imagePath;
  final bool isOtherUserMessage;
  final String pic;

  var formatterTime = new DateFormat('d MMMM kk:mm');   

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.fastOutSlowIn),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /* (!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? Container(
             margin: const EdgeInsets.only(right: 5.0,left: 10.0),
             child: new CircleAvatar(
               backgroundImage: NetworkImage(pic),
               backgroundColor: Colors.indigoAccent,
               /* child: new Text('defaultUserName[0]'), */
             ),
           ) : Container(), */
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(00.0),
                child: new Column(
                  crossAxisAlignment: (!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        /* borderRadius: (currentUser != null && senderUser != currentUser) ? BorderRadius.only(bottomRight: Radius.circular(20.0),bottomLeft:Radius.circular(1.0),topRight:Radius.circular(20.0),topLeft:Radius.circular(20.0)) : BorderRadius.only(bottomRight: Radius.circular(1.0),bottomLeft:Radius.circular(20.0),topRight:Radius.circular(20.0),topLeft:Radius.circular(20.0)), */
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        /* color: (currentUser != null && senderUser != currentUser) ? Color(0xFF6991C7).withOpacity(1) : Color(0xFF6991C7).withOpacity(0.6), */
                        color: (!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? Colors.grey[300] : Color(0xFF6991C7).withOpacity(1),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: (!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Row(                            
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Flexible(child: Text(txt, /* overflow: TextOverflow.ellipsis, */ style: TextStyle(color: (!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? Colors.black87 : Colors.white, fontFamily: 'Gotik'),))
                                /* Text(formatterTime.format(createdAt), style: TextStyle(color: Colors.white, fontSize: 12.0),) */
                              ],
                            ),
                          ),
                          createdAt != null ?
                          Text(formatterTime.format(createdAt), style: TextStyle(color:(!(isOtherUserMessage) || (currentUser != null && senderUser != currentUser)) ? Colors.black54 : Colors.white70, fontSize: 11.0, fontFamily: 'Gotik'),) : Container(width: 0.0,)
                        ], 
                      ),
                    ),
                  ],
                ),
              ),
            ),           
          ],
        ),
      ),
    );
  }
}

class NoMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:100.0),
            child: Center(
              child: Opacity(
                opacity: 0.5,
                  child: Image.asset("assets/imgIllustration/IlustrasiMessage.png",height: 220.0,)),
            ),
          ),
          Center(child: Text( AppLocalizations.of(context).tr('notHaveMessage'), style: TextStyle( fontWeight: FontWeight.w300,color: Colors.black12,fontSize: 17.0,fontFamily: "Popins"),))
        ],
      ),
    ));
  }
}
