import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
//import 'package:image_picker/image_picker.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  final isFromSignUp;

  const Profile({Key key,  this.isFromSignUp}) : super(key: key);

  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<Profile> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;

  SharedPreferences prefs;
  String _checkUserAuthImage;
  bool _isLoading = false;

  final nameController = TextEditingController();

//  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  var profilePic;
  String _selectedGender = "Select Gender";

//  Future getImage() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//
//    setState(() {
//      if (image != null) {
//        profilePic = image;
//      }
//    });
//  }

  @override
    void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
//              setState(() {
//                tap = 0;
//              });
            }
          });
    // TODO: implement initState
    super.initState();
    _getUserAuthImage();
    mapData();
  }

  void mapData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String name = await sharedPreferences.get("name");
    String gender = await sharedPreferences.get("gender");
    String address = await sharedPreferences.get("address");
    String dob = await sharedPreferences.get("dob");
    String phone = await sharedPreferences.get("phone");


    if (name !=null ){
      nameController.text = name;
    }
    if (gender !=null ){
      _selectedGender = gender;
    }

    if (address !=null ){
      addressController.text = address;
    }
    if (dob !=null ){
      dobController.text = dob;
    }
    if (phone !=null ){
      phoneController.text = phone;
    }

//
//    nameController.text = name;
////    genderController.text = gender;
//    _selectedGender = gender;
//    addressController.text = address;
//    dobController.text = dob;
//    phoneController.text = phone;
  }

  Future<Null> _getUserAuthImage() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkUserAuthImage = prefs.getString("authentication_page_image");
      print('hi');
      print(_checkUserAuthImage);
    });
  }

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
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Sample"),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: size.height,
              width: size.width,
              child: _checkUserAuthImage != null
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: _checkUserAuthImage,
                    )
                  : Image(
                      image:
                          AssetImage('assets/img/loginscreenbackground.png')),
            ),
            Container(
              color: Colors.transparent,
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
                                              20.0)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 70,
                                        width: 100,
                                        child: global.logo != null
                                            ? CachedNetworkImage(
//                                        height: 70,
//                                        width: 100,
                                                /* fit: BoxFit.cover, */
                                                imageUrl: global.logo,
                                              )
                                            : Image(
                                                image: AssetImage(
                                                    'assets/img/0.png')),
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
                                      Hero(
                                        tag: "Treva",
                                        child: Text(
                                          'Wolf Demo',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.6,
                                              color: Colors.white,
                                              fontFamily: "Sans",
                                              fontSize: 20.0),
                                        ),
                                      ),
//                                      InkWell(
//                                      child:Container(
//                                        width: 100.0,
//                                        height: 100.0,
//                                        child: CircleAvatar(
//                                          backgroundColor: Colors.white24,
//                                          backgroundImage: profilePic != null ? FileImage(profilePic): NetworkImage("_checkUserProfile")
//                                        ),
//                                      ),
//                                        onTap: (){
//                                        getImage();
//                                        },
//                                      ),
                                    ],
                                  ),

                                  /// ButtonCustomFacebook
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0)),

                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  textFromField(
                                    icon: Icons.person_outline,
                                    password: false,
                                    controller: nameController,
                                    email:
                                        'Name',
                                    inputType: TextInputType.text,
                                  ),

                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  genderDropDown(),
//                                  Padding(
//                                      padding:
//                                          EdgeInsets.symmetric(vertical: 5.0)),
//                                  textFromField(
//                                    icon: Icons.person,
//                                    password: false,
//                                    controller: genderController,
//                                    email: AppLocalizations.of(context)
//                                        .tr('Gender'),
//                                    inputType: TextInputType.text,
//                                  ),

                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  textFromField(
                                    icon: Icons.home,
                                    password: false,
                                    controller: addressController  ,
                                    email:'Address',
                                    inputType: TextInputType.text,
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
//                                  datePickerWidget(context),
                                  _buildDOBTextField(context),
//                                  textFromField(
//                                    icon: Icons.date_range,
//                                    password: false,
//                                    controller: dobController,
//                                    email: AppLocalizations.of(context)
//                                        .tr('Date of Birth'),
//                                    inputType: TextInputType.text,
//                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  textFromField(
                                    icon: Icons.phone_iphone,
                                    password: false,
                                    controller: phoneController,
                                    email: 'Phone',
                                    inputType: TextInputType.phone,
                                  ),

                                  /// TextFromField Password

                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: mediaQueryData.padding.top + 100.0,
                                        bottom: 50.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// Set Animaion after user click buttonLogin
                        InkWell(
                            splashColor: Colors.yellow,
                            onTap: () {
                              setState(() {
                                _isLoading = true;
                              });
                              updateProfile();
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 40),
                              child: !_isLoading ? updateButton() : /* Loader() */Center(child: Lottie.asset('assets/lottie/bouncing.json')),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: 20.0,
                left: 10.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Visibility(
                    visible: widget.isFromSignUp ? false : true,
                    child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                  ),
                )),
          ],
        ),
      ),
    );

  }

  void updateProfile() async {
    print('hi');
    if (validateTextFields()) {
      print('woo');
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String auth_token = sharedPreferences.get('token');

//      String profile_url = sharedPreferences.get('profile_url');
      String profile_url = 'https://cdn.filestackcontent.com/AFrHW1QRsWxmu5ZLU2qg';

      String tenant = Constants.tenant;
      print('name');
      print(nameController.text);
      print(phoneController.text);
      print(dobController.text);
      print(dobController.text);
      print(_selectedGender);
      print(addressController.text);
      print('ye masla hia ');
      print(profile_url);

      String updateProfileURL =
          "https://www.ondemandstaffing.app/api/v1/create_or_update_jobseeker?tenant=" + tenant + "&profileType=JobSeeker&name=" + nameController.text + "&contact_phone=" + phoneController.text + "&profile_url=" + profile_url + "&date_of_birth=" + dobController.text+ "&gender=" +_selectedGender+ "&address=" + addressController.text;

      Map<String, String> headers = {
        'AUTHORIZATION': auth_token
//        "Content-Type": "application/x-www-form-urlencoded",
      };

//
//      Map<String, String> dataDic = {
//        'tenant': tenant,
//        'profiletype': 'JobSeeker',
//        'name': nameController.text,
//        'contact_phone': phoneController.text,
//        'profile_url': profile_url,
//        'date_of_birth': dobController.text,
//        'gender': _selectedGender,
//        'address': addressController.text,
//      };
      print('data');
//      print(dataDic);

      try {
//        http.Response response = await http.post(updateProfileURL,
//            headers: headers, body: json.encode(dataDic));
    http.Response response = await http.post(updateProfileURL,
    headers: headers);
        var jsonResponse;
        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body);
          print(jsonResponse);

          var email = jsonResponse["user"]["email"].toString();
          sharedPreferences.setString("email", email);
          global.email = email;

          var name = jsonResponse["jobseeker"]["name"].toString();
          sharedPreferences.setString(
              "name", jsonResponse["jobseeker"]["name"]);
          global.name = name;

//          sharedPreferences.setString("profile_url", jsonResponse["jobseeker"]["profile_url"]);

          var user_code = jsonResponse["user"]["id"].toString();
//          global.profile_url = await sharedPreferences.get("profile_url");

          var user_type = jsonResponse["user"]["user_type"].toString();
          var myCustomUniqueUserId = jsonResponse["jobseeker"]["id"].toString();
          var created_at = jsonResponse["jobseeker"]["created_at"].toString();
          var city_id = jsonResponse["jobseeker"]["city_id"].toString();
          var updated_at = jsonResponse["jobseeker"]["updated_at"].toString();
          var longitude = jsonResponse["jobseeker"]["longitude"].toString();
          var user_type_code = jsonResponse["jobseeker"]["id"].toString();
          var user_id = jsonResponse["jobseeker"]["user_id"].toString();
          var date_of_birth =
              jsonResponse["jobseeker"]["date_of_birth"].toString();
          var latitude = jsonResponse["jobseeker"]["latitude"].toString();
          var contact_phone =
              jsonResponse["jobseeker"]["contact_phone"].toString();
          var active = jsonResponse["jobseeker"]["active"].toString();
          var gender = jsonResponse["jobseeker"]["gender"].toString();
          var token = jsonResponse["user"]["authentication_token"].toString();

          sharedPreferences.setString("token", token);
          sharedPreferences.setString("name", name);
          sharedPreferences.setString("gender", gender);
          sharedPreferences.setString(
              "address", jsonResponse["jobseeker"]["address"]);
          sharedPreferences.setString("dob", date_of_birth);
          sharedPreferences.setString("phone", contact_phone);

          if (widget.isFromSignUp) {
            bool pushNotificationAllowed = await OneSignal.shared
                .promptUserForPushNotificationPermission();

            OneSignal.shared
                .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
//        print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
              // will be called whenever the subscription changes
              //(ie. user gets registered with OneSignal and gets a user ID)
            });

            OneSignal.shared.setExternalUserId(myCustomUniqueUserId);

//      OneSignal.shared.setExternalUserId(myCustomUniqueUserId);
            var status =
                await OneSignal.shared.getPermissionSubscriptionState();
            String onesignalUserId = status.subscriptionStatus.userId;
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
            });

            print("One signal response is $resp");

            Map<String, dynamic> data1 = {
              "user_type": "JobSeeker",
              "name": global.name,
              "user_code": user_code,
              "user_type_code": user_type_code,
              "coordinates": onesignalUserId,
              "coordinates_type": "Onesignal",
              "tenant_key": Constants.tenant,
              "subscribed": pushNotificationAllowed
            };

            Map<String, dynamic> meta = {
              "test1": "some value",
              "another_key": "some other value"
            };

            Map<String, dynamic> CoordinateData = {
              'tenant': Constants.tenant,
              'key_action': 'update_coordinates',
              'api_key': "A4E1XpxAZf6f8Nmp0ZHxhA",
              'data': data1
//        'meta' : meta
            };

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
                print(jsonResponseCoordinate);
              } else {
                print(responseCoordinate.reasonPhrase);
              }
            } catch (err) {
              _isLoading = false;
              print("response error is: $err");
            }

//            new LoginAnimation(
//              animationController: sanimationController.view,
//            );
          }

          if (widget.isFromSignUp) {
            sharedPreferences.setBool("isLogin", true);
            showToast("Updated successfully!",
                duration: 4, gravity: Toast.BOTTOM);
//            _PlayAnimation();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => new Menu()));
          } else {
            setState(() {
              _isLoading = false;
              showToast("Updated successfully!",
                  duration: 4, gravity: Toast.BOTTOM);
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            jsonResponse = json.decode(response.body);
            showToast('Update error', duration: 4, gravity: Toast.BOTTOM);
          });
        }
      } catch (err) {
        print("response error is: $err");
        setState(() {
          _isLoading = false;
          showToast(err, duration: 4, gravity: Toast.BOTTOM);
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  bool validateTextFields() {
    if (nameController.text.isEmpty) {
      showToast("Please enter name!", gravity: Toast.BOTTOM);
      return false;
    }
    if (_selectedGender == "Select Gender") {
      showToast("Please enter gender!", gravity: Toast.BOTTOM);
      return false;
    }
    if (addressController.text.isEmpty) {
      showToast("Please enter address!", gravity: Toast.BOTTOM);
      return false;
    }
    if (dobController.text.isEmpty) {
      showToast("Please select date of birth!", gravity: Toast.BOTTOM);
      return false;
    }
    if (phoneController.text.isEmpty) {
      showToast("Please enter phone number!", gravity: Toast.BOTTOM);
      return false;
    }
    return true;
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Widget updateButton() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          'Next',
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

    Widget genderDropDown() {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        margin: EdgeInsets.symmetric(horizontal: 30.0),
        alignment: AlignmentDirectional.center,
        height: 60.0,

        padding: EdgeInsets.only(left: 0.0, right: 10.0, top: 0.0, bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.person, color: Colors.black38,),
          Container(
  //          height: 60,
          padding: EdgeInsets.only(left: 18),
            width: MediaQuery.of(context).size.width*0.65,
            child: DropdownButtonFormField<String>(
            icon: Icon(Icons.keyboard_arrow_down , size: 18,),
  //              itemHeight: 60,
                isDense: true,
                isExpanded: true,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Sans'
                ),


                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
                  labelStyle: new TextStyle(
                      fontSize:  15,
                      fontFamily: 'sans',
                      color: Colors.black38,
                      fontWeight: FontWeight.w600

                  ),
                  labelText: 'Gender',


                ),
  //        isExpanded: true,

                items: <String>['Select Gender', 'Hombre', 'Mujer', 'Otro']
                    .map((String val) {
                  return new DropdownMenuItem<String>(

                    value: val ,
                    child: Row(
                      children: <Widget>[
                        new Text(
                          val,
                          style: TextStyle(
                            color: Colors.black,
                          ),
  //                style: TitleTheme(
  //                  color: Colors.red[800],
  //                ),
                        ),
                      ],
                    ),

                  );
                }).toList(),
                value: _selectedGender  ,
  //              hint: Text(
  //                _selectedGender ,
  ////            style: TitleTheme(
  ////              color: isSelectedGender ? Colors.red[800] : Colors.grey[400],
  ////            ),
  //              ),
                validator: (value) => value == null || value == 'Please select a gender'
                    ? 'Gender type required'
                    : null,
                onChanged: (newVal) {
                  _selectedGender = newVal;
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(
                        () {
  //                _formData['gender'] = _selectedGender;
                    },
                  );
                },
              ),
          ),
          ],
        ),
      );
    }

  Widget _buildDOBTextField(BuildContext context) {
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
            controller: dobController ,
            decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(
                  Icons.date_range,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Sans',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              DatePicker.showDatePicker(
                context,
                initialDateTime: DateTime.now(),
                maxDateTime: DateTime.now(),
                dateFormat: 'MMM dd, yyyy',
                locale: DATETIME_PICKER_LOCALE_DEFAULT,
                pickerMode: DateTimePickerMode.date,
                pickerTheme: customTheme(),
                onConfirm: (dateTime, List<int> index) {
                  setState(() {
                    var _dateTime = dateTime;
                    String dateString =
                        new DateFormat("MMM dd, yyyy").format(_dateTime);
                    dobController.text = dateString;
                    print(dateString);
                  });
                },
              );
            },
            validator: (String value) {
              if (value.trim().isEmpty) {
                return "Please select date of birth.";
              }
            },
          ),
        ),
      ),
    );
  }

  DateTimePickerTheme customTheme() {
    return DateTimePickerTheme(
      confirmTextStyle: TextStyle(
        color: Colors.lightBlue,
      ),

      itemTextStyle: TextStyle(
        color: Colors.black38,
      ),
    );
  }
}
