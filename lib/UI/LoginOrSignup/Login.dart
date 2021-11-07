import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Signup.dart';
import 'package:http/http.dart' as http;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:translator/translator.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// Component Widget this layout UI
class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  final translator = GoogleTranslator();
  var tap = 0;

  @override

  /// set state animation controller
  void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    // TODO: implement initState
    _getUserAuthImage();
    createFolder();
    super.initState();    
  }

  void createFolder() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    if (await Directory(directory + '/' + Constants.tenant).exists() != true) {
      print("Directory not exists");
      new Directory(directory + '/' + Constants.tenant).createSync(recursive: true);
    } else {
      print("Directory exist");
    }
  }

  SharedPreferences prefs;
  String _checkUserAuthImage;

  Future<Null> _getUserAuthImage() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkUserAuthImage = prefs.getString("authentication_page_image");
//      print('hi');
//      print(_checkUserAuthImage);
    });
  }

  /// Dispose animation controller
  @override
  void dispose() {
    sanimationController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();

  loginTap() async {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(myEmailController.text)) {
      if (myPasswordController.text.isNotEmpty) {
        signUp(myEmailController.text, myPasswordController.text);
      } else {
        setState(() {
          _isLoading = false;
        });
        showToast("Please enter password!", gravity: Toast.BOTTOM);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showToast("Please Enter email!", gravity: Toast.BOTTOM);
    }
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  String tenant = Constants.tenant;


  signUp(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass, 'tenant': tenant};
    var jsonResponse;
    http.Response response = await http
        .post("http://www.ondemandstaffing.app/api/v1/sign_in", body: data);
    if (response.statusCode == 200) {
      HttpRequests().getTenant();
//      setState(() {
//        _isLoading = false;
//      });
      jsonResponse = json.decode(response.body);
      var success = jsonResponse["success"];
      print(jsonResponse);
//      print(success);
//      print(response.body);

      String email = jsonResponse["user"]["email"].toString();
      sharedPreferences.setString("email", email);
      if (jsonResponse["jobseeker"]["profiletype"] != null) {
        sharedPreferences.setString("hasResume", 'true');
        sharedPreferences.setString("resumeUrl", jsonResponse["jobseeker"]["profiletype"]);
      } else {
        sharedPreferences.setString("hasResume", 'false');
      }      
      global.email = email;

      String name = jsonResponse["jobseeker"]["name"].toString();
      sharedPreferences.setString("name", jsonResponse["jobseeker"]["name"]);
      global.name = name;

      sharedPreferences.setString(
          "profile_url", jsonResponse["jobseeker"]["profile_url"]);

      var user_code = jsonResponse["user"]["id"].toString();

      sharedPreferences.setString(
          "user_code", user_code);

      var userIDPre = jsonResponse["user"]["id"].toString();

      sharedPreferences.setString("userID", userIDPre);

      global.profile_url = sharedPreferences.get("profile_url");

      var user_type = jsonResponse["user"]["user_type"].toString();

      sharedPreferences.setString(
          "user_type", user_type);

      var myCustomUniqueUserId = jsonResponse["jobseeker"]["id"].toString();

      sharedPreferences.setString(
          "jobSeekerUniqueID", myCustomUniqueUserId);

      var created_at = jsonResponse["jobseeker"]["created_at"].toString();

      var city_id = jsonResponse["jobseeker"]["city_id"].toString();

      var updated_at = jsonResponse["jobseeker"]["updated_at"].toString();

      var longitude = jsonResponse["jobseeker"]["longitude"].toString();

      var user_type_code = jsonResponse["jobseeker"]["id"].toString();

      sharedPreferences.setString(
          "user_type_code", user_type_code);

      var user_id = jsonResponse["jobseeker"]["user_id"].toString();
      sharedPreferences.setString("user_id", user_id);

      var country_id = jsonResponse["jobseeker"]["country_id"].toString();

      var date_of_birth = jsonResponse["jobseeker"]["date_of_birth"].toString();

      var latitude = jsonResponse["jobseeker"]["latitude"].toString();

      var contact_phone = jsonResponse["jobseeker"]["contact_phone"].toString();

      var profile_url = jsonResponse["jobseeker"]["profile_url"].toString();

      var bio = jsonResponse["jobseeker"]["bio"].toString();

      var geoHash = jsonResponse["jobseeker"]["geoHash"].toString();

      var address = jsonResponse["jobseeker"]["address"].toString();

      var active = jsonResponse["jobseeker"]["active"].toString();

      var clearance_stamp =
          jsonResponse["jobseeker"]["clearance_stamp"].toString();

      var slug = jsonResponse["jobseeker"]["slug"].toString();

      var gender = jsonResponse["jobseeker"]["gender"].toString();

      var jobSeeker_token = jsonResponse["jobseeker"]["token"].toString();

      var profiletype = jsonResponse["jobseeker"]["profiletype"].toString();

      var contact_email = jsonResponse["jobseeker"]["contact_email"].toString();

      var token = jsonResponse["user"]["authentication_token"].toString();
      print("user token is $token");
      sharedPreferences.setString("token", jsonResponse["user"]["authentication_token"]);

      Segment.identify(userId: user_id, traits: {'email': global.email, 'user name' : name});


      if (gender == 'Mujer') {
          gender = 'Female';
        }
      if (gender == 'Hombre') {
        gender = 'Male';
      }

      sharedPreferences.setString("name", name);
      sharedPreferences.setString("gender", gender);

      print('genderrrr');
      print(gender);



      sharedPreferences.setString("address", jsonResponse["jobseeker"]["address"]);
      sharedPreferences.setString("dob", date_of_birth);
      sharedPreferences.setString("phone", contact_phone);




      //      OneSignal.shared.promptUserForPushNotificationPermission();
            /* bool pushNotificationAllowed = await OneSignal.shared.promptUserForPushNotificationPermission(); */
      bool pushNotificationAllowed;
      OneSignal.shared
          .setSubscriptionObserver((OSSubscriptionStateChanges changes) {

      });

      OneSignal.shared.setExternalUserId(myCustomUniqueUserId);

//      OneSignal.shared.setExternalUserId(myCustomUniqueUserId);
      var status = await OneSignal.shared.getPermissionSubscriptionState();
      String onesignalUserId = status.subscriptionStatus.userId;
      sharedPreferences.setString("onesignalUserId", onesignalUserId);
      print('onesignal id');
      print(onesignalUserId);

     var resp = await OneSignal.shared.sendTags({
        "created_at": created_at,
        "city_id": city_id,
        "updated_at": updated_at,
        "longitude": longitude,
        "id": user_type_code,
        "user_id": user_id,
        "active": active,
        "verified": date_of_birth,
        "latitude": latitude,
        "contact_phone": contact_phone,
//        "profile_url": profile_url,
////        "bio": bio,
//         "address": address,
//        "active": active,
//        "clearance_stamp": clearance_stamp,
//        "slug": slug,
//        "name": name,
//        "gender": gender,
//        "profiletype": profiletype,
//        "contact_email": contact_email,
//        "age": "0.4e2"
      });

     print("One signal response is $resp");

//      bool allowed = await OneSignal.shared.promptUserForPushNotificationPermission();
//      if(allowed){
//        print('yup');
//        print(allowed);
////        OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
//      }
//      print(allowed);

      Map <String, dynamic> data1 = {
//        "user_type": user_type,
        "user_type": "JobSeeker",
//        "name": "John Doe",
        "name": global.name,
        "user_code": user_code,
        "user_type_code": user_type_code,
//        "coordinates": myCustomUniqueUserId,
        "coordinates": onesignalUserId,
        "coordinates_type": "Onesignal",
        "tenant_key": tenant,
        "subscribed": pushNotificationAllowed != null ? pushNotificationAllowed : false
      };

      Map <String, dynamic> meta = {
        "test1": "some value", "another_key": "some other value"
      };


      Map <String, dynamic> CoordinateData = {
        'tenant': tenant,
        'key_action': 'update_coordinates',
//        'api_key': token,
        'api_key': Constants.api_key,
//        'api_key': jobSeeker_token,
        'data': data1
//        'meta' : meta
      };

      print('value');
      print(CoordinateData);

      try {
        var jsonResponseCoordinate;

        http.Response responseCoordinate = await http.post(
            "https://svk2a7wbej.execute-api.us-east-1.amazonaws.com/prod/",
            body: json.encode(CoordinateData));
        if (responseCoordinate.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          jsonResponseCoordinate = json.decode(responseCoordinate.body);
          print('value response');
          print(jsonResponseCoordinate);
        } else {
          print('value');
          print(responseCoordinate.reasonPhrase);
        }
      } catch (err) {
        print("response error is: $err");
      }

      sharedPreferences.setBool("isLogin", true);

      showToast("Login successful!", duration: 4, gravity: Toast.BOTTOM);

      new LoginAnimation(
        animationController: sanimationController.view,
      );

      _PlayAnimation();
      setState(() {
        tap = 1;
      });

      return tap;
    } else {
      setState(() {
        _isLoading = false;
        jsonResponse = json.decode(response.body);
        showToast('Incorrect Password', duration: 4, gravity: Toast.BOTTOM);
      });
    }
  }

  /// Playanimation set forward reverse
  ///
  ///
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.width;
    mediaQueryData.size.height;

    var data = EasyLocalizationProvider.of(context).data;
    var size = MediaQuery.of(context).size;

    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Container(
              height: size.height,
              width: size.width,
              child: _checkUserAuthImage != null
                  ? FancyShimmerImage(
                      shimmerBaseColor: Colors.black38,
                      shimmerHighlightColor: Colors.white,

                        boxFit: BoxFit.cover,
                        imageUrl: _checkUserAuthImage,
                        width: size.width,
                        height: size.height,
                    )
                  : Image(image: AssetImage('assets/img/loginscreenbackground.png') ,
                    fit: BoxFit.cover,height: MediaQuery.of(context).size.height,
                    width:  MediaQuery.of(context).size.width,
                  ),
            ),
            Container(
              color: Colors.transparent,

              /// Set Background image in layout (Click to open code)
//            decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: _checkUserAuthImage != null
//                      ? CachedNetworkImage(
//                    imageUrl: _checkUserAuthImage,
//                  )
//                      : AssetImage('assets/img/loginscreenbackground.png'),
////                ? NetworkImage(_checkUserAuthImage)
////                : AssetImage('assets/img/loginscreenbackground.png'),
//                  fit: BoxFit.cover,
//                )),
              child: Container(
                /// Set gradient color in image (Click to open code)
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.0),
                      Color.fromRGBO(0, 0, 0, 0.3)
                    ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                  ),
                ),

                /// Set component layout
                child: ListView(
                  children: <Widget>[
                    Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              alignment: AlignmentDirectional.topCenter,
                              child: Column(
                                children: <Widget>[
                                  /// padding logo
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: mediaQueryData.padding.top +
                                              40.0)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 70,
                                        width: 150,
                                        child: global.logo != null
                                            ? CachedNetworkImage(
//                                        height: 70,
//                                        width: 100,
//                                        fit: BoxFit.fitWidth,
                                                imageUrl: global.logo,
                                              )
                                            : Image(image: AssetImage('assets/img/0.png')),
                                      ),
//                                    Image(
//                                      image: global.logo != null
//                                          ? NetworkImage(global.logo)
//                                          : AssetImage('assets/img/0.png'),
//                                      height: 70.0,
//                                      width: 100,
//                                    ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0)),

                                      /// Animation text treva shop accept from signup layout (Click to open code)
//                                      Hero(
//                                        tag: "Treva",
//                                        child: Text(
//                                          'Wolf Demo',
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.w900,
//                                              letterSpacing: 0.6,
//                                              color: Colors.white,
//                                              fontFamily: "Sans",
//                                              fontSize: 20.0),
//                                        ),
//                                      ),
                                    ],
                                  ),

                                  /// ButtonCustomFacebook
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 70.0)),

                                  /// TextFromField Email
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0)),
                                  textFromField(
                                    icon: Icons.email,
                                    password: false,
                                    controller: myEmailController,
                                    email:'Email',
                                    inputType: TextInputType.emailAddress,
                                  ),

                                  /// TextFromField Password
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  textFromField(
                                    icon: Icons.vpn_key,
                                    password: true,
                                    controller: myPasswordController,
                                    email: 'Password',
                                    inputType: TextInputType.text,
                                  ),

                                  /// Button Signup
                                  ///

                                  FlatButton(
                                      padding: EdgeInsets.only(
                                          top: 20.0, bottom: 50),
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        new Signup()));
                                      },
                                      child: Text(
                                        'Not Have an Account? Sign Up',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Sans"),
                                      )),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: mediaQueryData.padding.top + 100.0,
                                        bottom: 20.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// Set Animaion after user click buttonLogin
                        tap == 0
                            ? InkWell(
                                splashColor: Colors.yellow,
                                onTap: () {
                                  setState(() {
//                                print('hi');
                                    _isLoading = true;
//                                tap = 1;
//                                print('wow');
                                    loginTap();
                                  });
//                              new LoginAnimation(
//                                animationController: sanimationController.view,
//                              );
//                              _PlayAnimation();
//                              return tap;
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 40),
                                  child:
                                      /* !_isLoading ?  */buttonSignin() /* : Loader() */,
                                ))
                            : new LoginAnimation(
                                animationController: sanimationController.view,
                              ),
                      ],
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

  Widget buttonSignin() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: !_isLoading ? Text(
          'Login',
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

  Widget Loader() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }
}

/// textfromfield custom class
class textFromField extends StatelessWidget {
  bool password;
  String email;
  IconData icon;
  TextEditingController controller;

  TextInputType inputType;

  textFromField(
      {this.email, this.icon, this.inputType, this.password, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: email,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Sans',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }
}

///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
         'Login',
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])
        ),
      ),
    );
  }
}
