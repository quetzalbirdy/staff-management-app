import 'dart:async';
import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:wolf_jobs/UI/chat/inbox.dart';
import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/Conversation.dart';
import 'package:wolf_jobs/model/JobListHolder.dart';
import 'package:wolf_jobs/model/Message.dart';
import 'package:wolf_jobs/model/PendingShiftsHolder.dart';
import 'package:wolf_jobs/model/ReportedTimesheet.dart';
import 'package:wolf_jobs/model/ShiftListHolder.dart';
import 'package:wolf_jobs/model/TimeSheet.dart';
import 'package:wolf_jobs/model/notificationHolder.dart';
import 'package:wolf_jobs/resources/json_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:wolf_jobs/resources/pusher_service.dart';

class HttpRequests {

  Future getTenant() async {    
    String apiKey = Constants.api_key;
    String tenant = Constants.tenant;
    Response res = await get(
        'https://3mpvy5eymh.execute-api.us-east-1.amazonaws.com/Production?tenant_db=$tenant&api_key=$apiKey',
//        headers: {'Content-Type': 'application/json; charset=utf-8'}
        );
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (res.statusCode == 200) {      
      var responseJson = json.decode((utf8.decode(res.bodyBytes)));
      print(responseJson);     

      /* custom profile fields */
      if (responseJson['gender_staff_status'] != null) {
        sharedPreferences.setString('askForGender', responseJson['gender_staff_status']);
      }
      if (responseJson['date_of_birth_ask_staff_status'] != null) {
        sharedPreferences.setString('askForDateBirth', responseJson['date_of_birth_ask_staff_status']);
      }
      if (responseJson['profile_pic_ask_staff_status'] != null) {
        sharedPreferences.setString('askForProfilePic', responseJson['profile_pic_ask_staff_status']);
      }

      /* Cancellation message for shift */
      if (responseJson['prefix_shift_cancellation_message'] != null) {
        sharedPreferences.setString('shiftCancellationMessage', responseJson['prefix_shift_cancellation_message']);
      }

      sharedPreferences.setString('onboardingTitle1', responseJson['native_apps_onboarding_1_tile']);  
      sharedPreferences.setString('onboardingDesc1', responseJson['native_apps_onboarding_1_desc']);  
      sharedPreferences.setString('onboardingTitle2', responseJson['native_apps_onboarding_2_tile']);  
      sharedPreferences.setString('onboardingDesc2', responseJson['native_apps_onboarding_2_desc']); 
      sharedPreferences.setString('onboardingTitle3', responseJson['native_apps_onboarding_3_tile']);  
      sharedPreferences.setString('onboardingDesc3', responseJson['native_apps_onboarding_3_desc']);       

      sharedPreferences.setString('shiftDeclineReasons', responseJson['candidate_decline_order_reasons']);                   

            
      sharedPreferences.setString('brand_color_primary_action',
          responseJson['brand_color_primary_action'].trim());      

      global.brand_color_primary_action =
          await sharedPreferences.get("brand_color_primary_action");

      sharedPreferences.setString('freelancer_date_based_view',
          responseJson['freelancer_date_based_view']);

      global.freelancer_date_based_view =
          await sharedPreferences.get("freelancer_date_based_view");

      sharedPreferences.setString(
          'tenant_key_unique', responseJson['tenant_key_unique']);

      global.tenant_key_unique =
          await sharedPreferences.get("tenant_key_unique");

      sharedPreferences.setString(
          'favicon_logo_square', responseJson['favicon_logo_square']);

      global.favicon_logo_square =
          await sharedPreferences.get("favicon_logo_square");

      sharedPreferences.setString('company_name', responseJson['company_name']);

      global.company_name = await sharedPreferences.get("company_name");

      sharedPreferences.setString(
          'signout_page_bg_pic', responseJson['signout_page_bg_pic']);

      global.signout_page_bg_pic =
          await sharedPreferences.get("signout_page_bg_pic");

      sharedPreferences.setString('logo_wide', responseJson['logo_wide']);

      global.logo_wide = await sharedPreferences.get("logo_wide");

      sharedPreferences.setString(
          'brand_color_action', responseJson['brand_color_action'].trim());

      global.brand_color_action =
          await sharedPreferences.get("brand_color_action");

      sharedPreferences.setString('logo', responseJson['logo']);

      global.logo = await sharedPreferences.get("logo");

      sharedPreferences.setString('authentication_page_image',
          responseJson['authentication_page_image']);

      global.authentication_page_image =
          await sharedPreferences.get("authentication_page_image");

      sharedPreferences.setString('brand_color_secondary_action',
          responseJson['brand_color_secondary_action'].trim());

      global.brand_color_secondary_action =
          await sharedPreferences.get("brand_color_secondary_action");

      sharedPreferences.setString(
          'brand_color_bg_light', responseJson['brand_color_bg_light'].trim());

      global.brand_color_bg_light =
          await sharedPreferences.get("brand_color_bg_light");

      sharedPreferences.setString(
          'brand_color_bg_dark', responseJson['brand_color_bg_dark'].trim());

      global.brand_color_bg_dark =
          await sharedPreferences.get("brand_color_bg_dark");

      sharedPreferences.setString('logo_square', responseJson['logo_square']);

      global.logo_square = await sharedPreferences.get("logo_square");

      sharedPreferences.setString(
          'brand_swatches', responseJson['brand_swatches']);

      global.brand_swatches = await sharedPreferences.get("brand_swatches");

      sharedPreferences.setString(
          'default_currency_symbol', responseJson['default_currency_symbol'].trim());

      global.default_currency_symbol =
          await sharedPreferences.get("default_currency_symbol");

      print(global.default_currency_symbol);

      sharedPreferences.setString(
          'login_page_bg_pic', responseJson['login_page_bg_pic']);

      global.login_page_bg_pic =
          await sharedPreferences.get("login_page_bg_pic");

      sharedPreferences.setString('brand_name', responseJson['brand_name']);

      global.brand_name = await sharedPreferences.get("brand_name");

      var brand_color_primary_action = sharedPreferences.getString('brand_color_primary_action');
//      print(responseJson);
          
      getGlobalMessages();
    }

//    setState(() {});
  }

  getGlobalMessages() async {
        var currentUser;  
        PusherService pusherService = PusherService();  
        var prefs = await SharedPreferences.getInstance();
        currentUser = prefs.getString("userID");
        print('${Constants.tenant}_u_${currentUser}_active');
        pusherService = PusherService();            
        pusherService.firePusher('${Constants.tenant}_u_${currentUser}_active', 'new_chat'); 
        pusherService.eventStream.listen((message) {         
          print(message);              
          /* Fluttertoast.showToast(            
            msg: '${json.decode(message)['name']}: ${json.decode(message)['message']}',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,

          );   */    
          /* showSimpleNotification(
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Container( margin: EdgeInsets.only(right:10.0),child: Icon(Icons.chat, color: Colors.blue,)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                  
                      Text('${json.decode(message)['name']}', style: TextStyle(color: Colors.black),),
                      Text('${json.decode(message)['message']}', style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                ],
              ),
            ),
            background: Colors.white,
            trailing: Builder(builder: (context) {
              return FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => ChatInbox()));
                  },
                  child: Text('Go to Inbox', style: TextStyle(color: Colors.black)));
            }),
            duration: Duration(milliseconds: 10000)
          );  */   
          showOverlayNotification((context) {
            return SafeArea(
              child: Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: Column(
                  children: [
                    ListTile(                                            
                      leading: SizedBox.fromSize(
                          size: const Size(40, 40),
                          child: ClipOval(
                              child: Image.network(json.decode(message)['picture']))),
                      title: Text('${json.decode(message)['name']}'),
                      subtitle: Text('${json.decode(message)['message']}'),
                      /*  trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context).dismiss();
                          }), */
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[200],
                      child: FlatButton(
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => ChatInbox()));
                          OverlaySupportEntry.of(context).dismiss();
                        },
                        child: Text('Review', style: TextStyle(color: Colors.black)))
                    )
                  ],
                ),
              ),
            );
          }, duration: Duration(milliseconds: 3000));                   
        });
      } 
  
  Future<List<ShiftListHolder>> getUpcomingShifts() async {
    List<Campaign> responseShift = [];
      List<ReportedTimesheet> responseTimesheet = [];
      String tenant = Constants.tenant;
      final String postsURL =
          "#/api/v1/shifts/view_all_upcoming_assigned_jobs/?tenant=" + tenant;
      List<ShiftListHolder> response = [];
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");
      print(token);
      Response res = await get(postsURL,
          headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);

        await JsonStorage('upcomingShifts').writeFile(json.encode(responseJson));      
        
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
            print('upcoming shifts');
            print(dataSort);

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
          return response;
        } else {
          return null;
        }
      }   
      return null;    
  }

  Future<List<PendingShiftsHolder>> getPendingShifts() async {
    List<Campaign> responseShift = [];
      List<ReportedTimesheet> responseTimesheet = [];
      String tenant = Constants.tenant;
      final String postsURL = "#/api/v1/shifts/view_past_tenders/?tenant=" + tenant;
      List<PendingShiftsHolder> response = [];
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");
      print(token);
      Response res = await get(postsURL,
          headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);

        await JsonStorage('pendingShifts').writeFile(json.encode(responseJson));  
        
        List<dynamic> dataHolder = responseJson['data']['shifts'];        

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
          return response;
        } else {
          return null;
        }
      }   
      return null;    
  }


  Future<List<JobListHolder>> getAvailableShifts() async {
  
      String tenant = Constants.tenant;
      List jobTypes; 
      final String postsURL =
          "#/api/v1/shifts/view_all_jobs/?tenant=" + tenant;
      List<JobListHolder> response = [];
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");
      print(token);
      Response res = await get(postsURL,
          headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);
        print(responseJson);      

        await JsonStorage('availableShifts').writeFile(json.encode(responseJson));      
        
        Map<String, dynamic> dataHolder = responseJson['data']['campaigns'];

        if (dataHolder != null) {
          for (int j = 0; j < dataHolder.length; j++) {
            var dataJob = dataHolder.values.toList()[j];
            var dataSort = dataHolder.values.toList();
            /* dataSort.sort((a, b) {
              var adate = a['start']; //before -> var adate = a.expiry;
              var bdate = b['start']; //before -> var bdate = b.expiry;
              return adate.compareTo(
                  bdate); //to get the order other way just switch `adate & bdate`
            });   */          
            JobListHolder models = JobListHolder.fromJson(dataSort[j]);            

            response.add(models);
            List jobs = [];
            for (var count = 0; count < response.length; count++) {
              if (jobs.contains(response[count].job_type)) {
                continue;
              } else {        
                jobs.add(response[count].job_type);
              }
            }    
            jobTypes = jobs; 
            jobTypes.sort();              
          }
          return response;
        } else {
          return null;
        }
      }   
      return null;    
  }

  Future<List<TimeSheet>> getTimeSheets() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String tenant = Constants.tenant;
      String apiKey = Constants.api_key;
      List jobTypes; 
      var token = sharedPreferences.getString("token");
      var jobseekerID = sharedPreferences.getString("jobSeekerUniqueID");
      List<TimeSheet> response = [];      
      List<TimeSheet> filterResponse = []; 
      final String postsURL = "https://7ax3q0jpx5.execute-api.us-east-1.amazonaws.com/prod?tenant="+tenant+"&api_key=$apiKey&jobseeker_id="+jobseekerID;           
      print(postsURL);
      Response res = await get(postsURL);
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);
        print(responseJson);      

        await JsonStorage('timeSheets').writeFile(json.encode(responseJson));      
        
        var dataHolder = responseJson;
        if (dataHolder != null) {
          for (int j = 0; j < dataHolder.length; j++) {
            var dataJob = dataHolder[j];                              
            TimeSheet models = TimeSheet.fromJson(dataJob);
            DateTime dateTimeCreatedAt =  DateFormat("yyyy-MM-dd HH:mm:ss").parse(models.created_at, true/* models.created_at , true */);          
            DateTime dateTimeNow = DateTime.now();
            final differenceInDays = dateTimeNow.difference(dateTimeCreatedAt).inHours;     
            response.add(models);
            if (differenceInDays <= 48){              
              filterResponse.add(models);                      
            }
          }
          return response;
        } else {
          return null;
        }
      }   
      return null;    
  }

  Future<List<Notiification>> getNotifications() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();      
      String _checkUserId = sharedPreferences.getString("userID");
      String tenant = Constants.tenant;        
      String apiKey = Constants.api_key;    
      List<Notiification> response = [];            
      final String postsURL = "#/prod?user_id=$_checkUserId&api_key=$apiKey&tenant="+tenant;  
      print(postsURL);          
      
      Response res = await get(postsURL);
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(res.bodyBytes));
        print(responseJson);      

        await JsonStorage('notifications').writeFile(json.encode(responseJson));      
        
        var dataHolder = responseJson;
        if (dataHolder != null) {
          for (int j = 0; j < dataHolder.length; j++) {
            var dataJob = dataHolder[j];
            Notiification models = Notiification.fromJson(dataJob);
            if (models.content_type == 'new_notification' ||  models.content_type == 'notification'){
              response.add(models);
            }
          }
          return response;
        } else {
          return null;
        }
      }   
      return null;    
  }

  Future<String> setReadNotifications() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();      
      String _checkUserId = sharedPreferences.getString("userID");
      String tenant = Constants.tenant;    
      String apiKey = Constants.api_key;        
      List<Notiification> response = [];            
      final String postsURL = "#/prod?user_id=$_checkUserId&api_key=$apiKey&tenant="+tenant+"&category=read_status_update";            
      
      Response res = await get(postsURL);
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);
        print(responseJson);    
        return responseJson['status'];         
      } else {
        return null;
      }
  } 

  Future<int> getUnreadNotificationsAmount() async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();      
      String _checkUserId = sharedPreferences.getString("userID");
      String tenant = Constants.tenant;   
      String apiKey = Constants.api_key;         
      List<Notiification> response = [];            
      final String postsURL = "#/prod?user_id=$_checkUserId&api_key=$apiKey&tenant="+tenant+"&category=unread_count";            
      
      Response res = await get(postsURL);
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);        
        return responseJson['unread_count'];                  
      } else {
        return null;
      }
  }  

  Future<List> getCustomJsonForms() async {                   
      String tenant = Constants.tenant;                    
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");        
      final String postsURL = "#/api/v1/jobseeker/get_custom_onboarding?tenant=$tenant&labs=true";            
      
      Response res = await get(postsURL, headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);
        print('custom forms');
        print(token);
        print(responseJson);
        return responseJson;                  
      } else {
        return null;
      }
  } 

  Future updateCustomForm(formData) async {                   
      String tenant = Constants.tenant;              
      List<Notiification> response = [];    
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");        
      final String postsURL = "#/api/v1/jobseeker/get_custom_onboarding?tenant=$tenant&form_submission=$formData";            
      print('post url');
      print(postsURL);

      Response res = await post(postsURL, headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body); 
        print('response');
        print(jsonDecode(res.body));
        print('token');
        print(token);
        return responseJson;                  
      } else {
        return null;
      }
  }   

  Future getJobTypes() async {                   
      String tenant = Constants.tenant;              
      List<Notiification> response = [];    
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");        
      final String postsURL = "#/api/v1/shifts/jobseeker_jobtype_preferences?tenant=$tenant";                  

      Response res = await get(postsURL, headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body);        
        return responseJson;                  
      } else {
        return null;
      }
  } 

  Future setJobTypes(jobTypes) async {                   
      String tenant = Constants.tenant;              
      List<Notiification> response = [];    
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");        
      final String postsURL = "#/api/v1/shifts/jobseeker_jobtype_preferences?tenant=$tenant&jobtypes=${jobTypes}"; 
      print('post url');
      print(postsURL);
      
      Response res = await post(postsURL, headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        var responseJson = jsonDecode(res.body); 
        print('token');
        print(token);
        print('response');
        print(jsonDecode(res.body));
        return responseJson;                  
      } else {
        return null;
      }
  }     

  Future<String> declineShifts(shiftList, reason) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final Map<String, dynamic> data = {
      'message': 'decline',
      'decline_reason': reason,
      'shifts': shiftList,
      'tenant': Constants.tenant
    };
    var jsonResponse;
    Response response = await post(
      'http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/',
      headers: {
        'Content-Type': 'application/json',
        'AUTHORIZATION': token,
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return "Job declined";
      /* Flushbar(
//        title:  responseJson['message'],
        message: 'Request Sent',
        duration: Duration(seconds: 3),
      )..show(context); */      
    } else {
//      print(response.body);
      return jsonResponse["message"];
    }    
  }

  Future getInbox() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");        
    String _checkUserId = sharedPreferences.getString("userID");
    String apiKey = Constants.api_key;    
    var jsonResponse;
    List<Conversation> responseList = [];
    Response response = await get(
      'https://12xow7tdad.execute-api.us-east-1.amazonaws.com/production?user_id=$_checkUserId&tenant=${Constants.tenant}&api_key=$apiKey',
      headers: {
        'Content-Type': 'application/json',
        'AUTHORIZATION': token,
      },      
    );

    if (response.statusCode == 200) {      
      var responseJson = jsonDecode(response.body);   
      await JsonStorage('inbox').writeFile(json.encode(responseJson));                     

      if (responseJson != null) {
        for (var i = 0; responseJson.length > i; i++) {
          Conversation models = Conversation.fromJson(responseJson[i]);          
          responseList.add(models);
        }           
      }
 
      return responseList;
      /* Flushbar(
//        title:  responseJson['message'],
        message: 'Request Sent',
        duration: Duration(seconds: 3),
      )..show(context); */      
    } else {
//      print(response.body);
      return 'Not working';
    }    
  }

  Future getMessages(chatKey) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");        
    String _checkUserId = sharedPreferences.getString("userID");
    String apiKey = Constants.api_key;    
    var jsonResponse;
    List<Message> responseList = [];
    Response response = await get(
      'https://9zie5pgzja.execute-api.us-east-1.amazonaws.com/production?user_id=$_checkUserId&tenant=${Constants.tenant}&api_key=$apiKey&chat_key=$chatKey',
      headers: {
        'Content-Type': 'application/json',
        'AUTHORIZATION': token,
      },      
    );

    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);     
      await JsonStorage('conversation$chatKey').writeFile(json.encode(responseJson));                

      if (responseJson != null) {
        for (var i = 0; responseJson.length > i; i++) {
          Message models = Message.fromJson(responseJson[i]);          
          responseList.add(models);
        }           
      }
 
      return responseList;
      /* Flushbar(
//        title:  responseJson['message'],
        message: 'Request Sent',
        duration: Duration(seconds: 3),
      )..show(context); */      
    } else {
//      print(response.body);
      return 'Not working';
    }    
  }

  Future sendMessage(chatKey, message) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");        
    String _checkUserId = sharedPreferences.getString("userID");
    String apiKey = Constants.api_key;    
    var jsonResponse;    
    print('https://9zie5pgzja.execute-api.us-east-1.amazonaws.com/production?sender_id=$_checkUserId&tenant=${Constants.tenant}&api_key=$apiKey&chat_key=$chatKey&message=$message');
    Response response = await post(
      'https://9zie5pgzja.execute-api.us-east-1.amazonaws.com/production?sender_id=$_checkUserId&tenant=${Constants.tenant}&api_key=$apiKey&chat_key=$chatKey&message=$message',
      headers: {
        'Content-Type': 'application/json',
        'AUTHORIZATION': token,
      },      
    );

    if (response.statusCode == 200) {
      var responseJson = response.body;                        

      return responseJson;
      /* Flushbar(
//        title:  responseJson['message'],
        message: 'Request Sent',
        duration: Duration(seconds: 3),
      )..show(context); */      
    } else {
//      print(response.body);
      return 'Not working';
    }    
  }

  /* Future shiftUpdate(String id, String freelanerID, String message, now, out, context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String postsURLShifts = "http://www.ondemandstaffing.app/api/v1/shifts/shift_update_status/";
    var token = sharedPreferences.getString("token");    
    final Map<String, dynamic> data = {
      'message': message,
      'shifts'/* 'shifts' */: id,
      'freelancer_id': freelanerID,
      'tenant': Constants.tenant,
      'check_in_time': now,
      'check_out_time': out
    };
    var jsonResponse;
    Response res = await post(
      postsURLShifts,
      headers: {'AUTHORIZATION': token, 'Content-Type': 'application/json'/* HttpHeaders.authorizationHeader : token, 'Content-Type': 'application/json' */},
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {      
      print('data');
      print(data);
      var responseJson = jsonDecode(res.body);
      print('responseJson');
      print(responseJson);
      Toast.show('You have updated your hours', context, duration: 4, gravity:Toast.BOTTOM);            
    } else {
      var responseJson = jsonDecode(res.body);
      Toast.show(responseJson["message"], context, duration: 4, gravity:Toast.BOTTOM);                  
    }
  }   */      
}