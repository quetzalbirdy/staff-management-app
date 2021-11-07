import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
/* import 'package:json_to_form/json_schema.dart'; */
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wolf_jobs/Library/json_to_form/json_to_form.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/account_settings.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/signUpDone.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Menu.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/resources/globalData.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:html/parser.dart';

class CustomForms extends StatefulWidget {  
  final forms;
  final index;
  final isFromAccountSettings;
  
  CustomForms({
    this.forms,
    this.index,
    this.isFromAccountSettings
  });

  @override
  _CustomFormsState createState() => _CustomFormsState();
}

class _CustomFormsState extends State<CustomForms> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();    
    getForms();       
    /* print(json.encode(json1[1]));    */
  }    

  bool _isLoading = false;
  bool loagingButton = false;
  
  List jsonForms;
  int formIndex;
  int formsToLast;
  getForms() async {
    if (widget.forms == null) {   
      setState(() {
        pageLoading = true;  
      });   
      await HttpRequests().getCustomJsonForms().then((forms) {
        setState(() {
          jsonForms = forms;   
          formsToLast = jsonForms.length;
          formIndex = 0;          
        });
      });
    } else {
      setState(() {   
        pageLoading = false; 
        jsonForms = widget.forms;          
        if (widget.index != null) {
          formIndex = widget.index;
          formsToLast = jsonForms.length - (formIndex + 1);
        }            
      });
    }
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

  Widget updateButton() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: !_isLoading ? Text(
          widget.isFromAccountSettings != null ? 'Update' : formsToLast == 0 ? 'Done' : 'Next',
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }

  String _totalCount = "";
  String _checkUserId = "";
  String tenant = Constants.tenant;
  bool pageLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: /* const Color(0xFFDDE4F0) */Colors.white,
        appBar: AppBar(
          title: Text(
            'Onboarding',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme:
              IconThemeData(color: hexToColor(global.brand_color_bg_light)),
          elevation: 0.0,
        ), 
        body: jsonForms != null ? Container(
          margin: EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 1,
                itemBuilder: (context, index) {    
                  if (jsonForms[index]['custom_form_content'] != "") {  
                    var script = jsonForms[index]['custom_form_content'];    
                    print(script.split('src')[1].split("'")[1]);   
                  }                                                               
                  /* if (jsonForms[index]['custom_form_content'] != "") {                    
                    var script = jsonForms[index]['custom_form_content'];                    
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: WebView(                      
                        initialUrl: script.split('src')[1].split("'")[1],
                        javascriptMode: JavascriptMode.unrestricted,
                        onPageFinished: (finish) {
                          setState(() {
                            pageLoading = false;                
                          });
                        },
                      ),
                    );
                  } else {
                    return JsonToForm(
                      form: json.encode(jsonForms[index]), 
                      onChanged: (dynamic response) {
                          /* this.response = response; */
                      },
                      actionSave: (data) {
                          print(data);
                      },
                      buttonSave: new Container(
                        height: 40.0,                    
                        color: hexToColor(global.brand_color_primary_action),                                
                        child: Center(
                            child: Container(child: Text('Upload Form', style: TextStyle(color: Colors.white),)),
                        ),
                    ),
                    ); 
                  }  */
                  return Column(
                    children: <Widget>[                      
                      JsonToForm(                        
                        form: json.encode(jsonForms[formIndex]), 
                        onChanged: (dynamic response) {
                            /* this.response = response; */
                        },
                        actionSave: (data) async {  
                          print(jsonForms[formIndex]['custom_form_content']);
                          if (jsonForms[formIndex]['custom_form_content'].isNotEmpty) {
                            if (widget.isFromAccountSettings != null) {
                              Navigator.of(context).pop();
                            } else {
                                if (formsToLast == 0) {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => new CustomForms(forms: jsonForms, index: formIndex + 1)));
                              } 
                            }
                          } else {
                            setState(() {
                              loagingButton = true;                            
                            });                        
                            var fields = [];                      
                            for (var field in data['fields']) {
                              if (field['type'] != 'File') {
                                fields.add({'custom_requirement_id': field['key'], 'value': field['value']});                                                              
                              } 
                            }
                            print(json.encode(fields)); 
                            await HttpRequests().updateCustomForm(json.encode(fields).toString()).then((data) {
                              setState(() {
                                loagingButton = false;                            
                              }); 
                            });                                                   
                            if (widget.isFromAccountSettings != null) {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new AccountSettings()));
                            } else {
                              if (formsToLast == 0) {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new SignUpDone()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => new CustomForms(forms: jsonForms, index: formIndex + 1)));
                              }
                            }
                          }                          
                        },                        
                        buttonSave: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, left: 30.0, right: 30.0),
                              child: Divider(
                                color: Colors.black12,
                                height: 2.0,
                              ),
                            ),                            
                            Padding(
                              padding:EdgeInsets.only(left: 20,right: 20,bottom: 0,top: 0),
                              child: new Container(
                                margin: EdgeInsets.only(bottom: 0.0),
                                height: 55.0,
                //                        width: 600.0,
                                child: /* Center(child: SizedBox(height: 25.0, width: 25.0, child: CircularProgressIndicator(valueColor : AlwaysStoppedAnimation(Colors.white), strokeWidth: 2.0,),),) :  */
                                /* loagingButton == false ? */
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[                                
                                    SizedBox(width: 10,),
                                    loagingButton == false ?
                                    Text(
                                      widget.isFromAccountSettings != null ? 'Update' : formsToLast == 0 ? 'Done' : 'Next',
                                      style: TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                          fontFamily: "Sans",
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w800),
                                    ) : Container(child: Lottie.asset(Constants.buttonLoadingAnimation),),

                                  ],
                                ) /* : Center(child: SizedBox(height: 30.0, width: 30.0, child: CircularProgressIndicator(valueColor : AlwaysStoppedAnimation(Colors.white), strokeWidth: 1.5,),),) */,
                                alignment: FractionalOffset.center,
                                decoration: BoxDecoration(
                                    boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
                                    borderRadius: BorderRadius.circular(30.0),
                                    gradient: LinearGradient(
                                        colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
                                ),               
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );                                 
                }
              ),
              /* Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 30.0, right: 30.0),
                child: Divider(
                  color: Colors.black12,
                  height: 2.0,
                ),
              ), */
              /* InkWell(
                splashColor: Colors.yellow,
                onTap: () {
                  /* FocusScope.of(context)
                      .requestFocus(new FocusNode());
                  setState(() {
                    _isLoading = true;
                  });
                  updateProfile(); */
                  if (formsToLast == 0) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => new HomePage()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => new CustomForms(forms: jsonForms, index: formIndex + 1)));
                  }             
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: /* !_isLoading ?  */updateButton() /* : Loader() */,
                )), */
            ],
          ),
        ) : Container(
          child: Center(
            child: CircularProgressIndicator(),
          )
        )
    );
  }
}