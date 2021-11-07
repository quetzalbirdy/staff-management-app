import 'dart:async';
import 'dart:convert';

import 'package:lottie/lottie.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Profile.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/UI/BottomNavigationBar.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:toast/toast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/resources/httpRequests.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  Animation animationScreen;
  var tap = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _selectedType = "Select Role";

  /// Set AnimationController to initState
  @override
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
    super.initState();
    _getUserAuthImage();
  }

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

  /// Dispose animationController
  @override
  void dispose() {
    sanimationController.dispose();
    super.dispose();
  }

  /// Playanimation set forward reverse
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
    mediaQueryData.size.height;
    mediaQueryData.size.width;

    var screenSize = MediaQuery.of(context).size;

    var data = EasyLocalizationProvider.of(context).data;

    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            backgroundImage(screenSize),
            Container(
              color: Colors.transparent,
              child: Container(
                /// Set gradient color in image
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
                  padding: EdgeInsets.all(0.0),
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
                                              55.0)),
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
//                                      Image(
//                                        image: AssetImage("assets/img/Logo.png"),
//                                        height: 70.0,
//                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0)),

                                      /// Animation text treva shop accept from login layout
//                                      Hero(
//                                        tag: "Treva",
//                                        child: Text(
////                                          AppLocalizations.of(context).tr('title'),
//                                          'Wolf Demo',
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.w900,
//                                              letterSpacing: 0.6,
//                                              fontFamily: "Sans",
//                                              color: Colors.white,
//                                              fontSize: 20.0),
//                                        ),
//                                      ),
                                    ],
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 80.0)),
                                        textFromField(
                                          icon: Icons.email,
                                          password: false,
                                          controller: emailController,
                                          email:'Email',
                                          inputType: TextInputType.emailAddress,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0)),

                                        /// TextFromField Password
                                        textFromField(
                                          icon: Icons.vpn_key,
                                          password: true,
                                          controller: passwordController,
                                          email: "Password",
                                          inputType: TextInputType.text,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0.0)),
//                                        buildUserTypeDropDown()
//                                      Container(
//                                        margin: EdgeInsets.symmetric(horizontal: 30.0),
//                                        height: 60.0,
//                                        alignment: AlignmentDirectional.center,
//                                        decoration: BoxDecoration(
//                                            borderRadius: BorderRadius.circular(14.0),
//                                            color: Colors.white,
//                                            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
//                                        padding:
//                                        EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
//
//                                        child: DropdownButton<String>(
//                                          value: dropdownValue,
//                                          icon: Icon(Icons.arrow_downward),
//                                          iconSize: 24,
//                                          elevation: 16,
//                                          style: TextStyle(
//                                              color: Colors.deepPurple
//                                          ),
//                                          underline: Container(
//                                            height: 2,
//                                            color: Colors.deepPurpleAccent,
//                                          ),
//                                          onChanged: (String newValue) {
//                                            setState(() {
//                                              dropdownValue = newValue;
//                                            });
//                                          },
//                                          items: <String>['One', 'Two', 'Free', 'Four']
//                                              .map<DropdownMenuItem<String>>((String value) {
//                                            return DropdownMenuItem<String>(
//                                              value: value,
//                                              child: Text(value),
//                                            );
//                                          }).toList(),
//                                        ),
//                                      ),
                                      ],
                                    ),
                                  ),

                                  /// TextFromField Email

                                  /// Button Login
                                  FlatButton(
                                      padding: EdgeInsets.only(top: 20.0, bottom: 50),
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        new LoginScreen()));
                                      },
                                      child: Text(
                                        'Have an Account? Sign In',
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
                                  )
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
                                    _isLoading = true;
                                    signUpClicked();
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 40),
                                  child:
                                  /* !_isLoading ?  */buttonSignin() /* : Loader() */,
                                ),
//                                buttonBlackBottom(),
                              )
                            : new LoginAnimation(
                                animationController: sanimationController.view,
                              )
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
          'Sign up',
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

  Widget buildUserTypeDropDown() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      alignment: AlignmentDirectional.center,
      height: 60.0,
      padding: EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: -10.0),
          border: InputBorder.none,
        ),
//        isExpanded: true,
        items:
            <String>['Select Role', 'freelancer', 'company'].map((String val) {
          return new DropdownMenuItem<String>(
            value: val,
            child: new Text(
              val,
              style: TextStyle(
                color: Colors.grey,
              ),
//                style: TitleTheme(
//                  color: Colors.red[800],
//                ),
            ),
          );
        }).toList(),
        value: _selectedType,
        hint: Text(
          _selectedType,
//            style: TitleTheme(
//              color: isSelectedGender ? Colors.red[800] : Colors.grey[400],
//            ),
        ),
        validator: (value) => value == null || value == 'Please select a role'
            ? 'Role type required'
            : null,
        onChanged: (newVal) {
          _selectedType = newVal;
          FocusScope.of(context).requestFocus(FocusNode());
          setState(
            () {
//                _formData['gender'] = _selectedGender;
            },
          );
        },
      ),
    );
  }

  Widget backgroundImage(var screenSize) {
    return Container(
      height: screenSize.height,
      width: screenSize.width,
      child: _checkUserAuthImage != null
          ? CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: _checkUserAuthImage,
            )
          : Image(image: AssetImage('assets/img/loginscreenbackground.png'),
          fit: BoxFit.cover,height: MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.width,
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

  void signUpClicked() async {
    print('oh ye');
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(emailController.text)) {
      if (passwordController.text.isNotEmpty &&
          passwordController.text.length > 7) {
          HttpRequests().getTenant();
          signUp(emailController.text, passwordController.text);
//        if (_selectedType != "Select Role") {
//          signUp(emailController.text, passwordController.text);
//        } else {
//          setState(() {
//            _isLoading = false;
//          });
//          showToast("Please select role", gravity: Toast.BOTTOM);
//        }
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
    print('working');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'email': email,
      'password': pass,
      'tenant': tenant,
//      'role': _selectedType
        'user_type': "freelancer"
    };

    var jsonResponse;
    http.Response response = await http
        .post("https://www.ondemandstaffing.app/api/v1/sign_up", body: data);
    print(response.body);
    if (response.statusCode == 200) {      
      setState(() {
//        _isLoading = false;
      });
      jsonResponse = json.decode(response.body);
      var success = jsonResponse["success"];
      print(jsonResponse);
//      print(success);
//      print(response.body);
      sharedPreferences.setString("email", jsonResponse["user"]["email"]);

      global.email = await sharedPreferences.get("email");

      var myCustomUniqueUserId = jsonResponse["user"]["id"].toString();

      var created_at = jsonResponse["user"]["created_at"].toString();

      var city_id = jsonResponse["user"]["city_id"].toString();

      var updated_at = jsonResponse["user"]["updated_at"].toString();

      var longitude = jsonResponse["user"]["longitude"].toString();

      var id = jsonResponse["user"]["id"].toString();
      var userIDPre = jsonResponse["user"]["id"].toString();
      sharedPreferences.setString("userID", userIDPre);

      var user_id = jsonResponse["user"]["user_id"].toString();

      var user_type = jsonResponse["user"]["user_type"].toString();

      var country_id = jsonResponse["user"]["country_id"].toString();

      var date_of_birth = jsonResponse["user"]["date_of_birth"].toString();

      var latitude = jsonResponse["user"]["latitude"].toString();

      var contact_phone = jsonResponse["user"]["contact_phone"].toString();


      var active = jsonResponse["user"]["active"].toString();

      var clearance_stamp =
          jsonResponse["user"]["clearance_stamp"].toString();

      var slug = jsonResponse["user"]["slug"].toString();

      var name = jsonResponse["user"]["name"].toString();

      var gender = jsonResponse["user"]["gender"].toString();

      var profiletype = jsonResponse["user"]["profiletype"].toString();

      var contact_email = jsonResponse["user"]["contact_email"].toString();

      var token = jsonResponse["user"]["authentication_token"].toString();

      sharedPreferences.setString("token", jsonResponse["user"]["authentication_token"]);

      bool pushNotificationAllowed = await OneSignal.shared.promptUserForPushNotificationPermission();

      OneSignal.shared
          .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
//        print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
        // will be called whenever the subscription changes
        //(ie. user gets registered with OneSignal and gets a user ID)
      });

      OneSignal.shared.setExternalUserId(myCustomUniqueUserId);

//      OneSignal.shared.setExternalUserId(myCustomUniqueUserId);
      var status = await OneSignal.shared.getPermissionSubscriptionState();
      String onesignalUserId = status.subscriptionStatus.userId;
      print('onesignal id');
      print(onesignalUserId);

      await OneSignal.shared.sendTags({
        "created_at": created_at,
        "city_id": city_id,
        "updated_at": updated_at,
        "longitude": longitude,
        "id": id,
        "user_id": user_id,
        "active": active,
        "verified": date_of_birth,
        "latitude": latitude,
        "contact_phone": contact_phone,

      });

//      bool allowed = await OneSignal.shared.promptUserForPushNotificationPermission();
//      if(allowed){
//        print('yup');
//        print(allowed);
////        OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
//      }
//      print(allowed);

      Map<String, dynamic> data1 = {
//        "user_type": "JobSeeker",
        "user_type": user_type,
        "name": "",
        "user_code": 23,
        "user_type_code": 414,
//        "coordinates": myCustomUniqueUserId,
        "coordinates": onesignalUserId,
        "coordinates_type": "Onesignal",
        "tenant_key": tenant,
        "subscribed": pushNotificationAllowed
      };

      Map<String, dynamic> meta = {
        "test1": "some value",
        "another_key": "some other value"
      };

      Map<String, dynamic> CoordinateData = {
        'tenant': tenant,
        'key_action': 'update_coordinates',
//        'api_key': token,
        'api_key': "A4E1XpxAZf6f8Nmp0ZHxhA",
        'data': data1,
        'meta': meta
      };

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
          print(jsonResponseCoordinate);
        } else {
          print(responseCoordinate.reasonPhrase);
        }
      } catch (err) {
        setState(() {
          _isLoading = false;
        });
        print("response error is: $err");
        showToast(err, duration: 4, gravity: Toast.BOTTOM);
      }

      sharedPreferences.setBool("isLogin", true);

      /* showToast("Sign up successful!", duration: 4, gravity: Toast.BOTTOM); */

      new LoginAnimation(
        animationController: sanimationController.view,
      );

//      _PlayAnimation();

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => new profil(isFromSignUp: true)));

      /* Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => JobType())); */

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

/* ///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: !_isLoading ? Text(
          'Signup',
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
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }
}
 */