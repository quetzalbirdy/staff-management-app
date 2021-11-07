import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/account_settings.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/filePicker.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/showResume.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/AdditionalForm.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/testForm.dart';
import 'package:async/async.dart';

import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/Notification.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/JobTypePreferences.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Signup.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;
import 'package:wolf_jobs/globals.dart' as global;
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import 'package:translator/translator.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';

class profil extends StatefulWidget {
  final isFromSignUp;
  final isFromAccountSettings;
  const profil({Key key, this.isFromSignUp, this.isFromAccountSettings}) : super(key: key);
  @override
  _profilState createState() => _profilState();
}

/// Custom Font
var _txt = TextStyle(
  color: Colors.black,
  fontFamily: "Sans",
);

/// Get _txt and custom value of Variable for Name User
var _txtName = _txt.copyWith(fontWeight: FontWeight.w700, fontSize: 17.0);

/// Get _txt and custom value of Variable for Edit text
var _txtEdit = _txt.copyWith(color: Colors.black26, fontSize: 15.0);

/// Get _txt and custom value of Variable for Category Text
var _txtCategory = _txt.copyWith(
    fontSize: 14.5, color: Colors.black54, fontWeight: FontWeight.w500);

var translationValue;

class _profilState extends State<profil> with TickerProviderStateMixin {
  String Male = 'Male';
  String Female = "Female";
  String Mujer = 'Mujer';
  String Hombre = "hombre";

  /* AnimationController sanimationController; */

  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;

  SharedPreferences prefs;
  String _checkUserAuthImage;
  bool _isLoading = false;
  bool _isLoadingSecondary = false;
  final translator = GoogleTranslator();

  final nameController = TextEditingController();

//  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  File _profilePic;
  String _selectedGender = "Select Gender";
  File _imageFile;
  File _anyFile;
  String profileType;
  var FileStackImageUrl;

  String _gender;
  String _translation;
  String checkProfile;

  SharedPreferences sharedPrefs;
  TextEditingController _controller = new TextEditingController();

  List<String> docPaths;
  

  @override
  void initState() {
   /*  sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
//              setState(() {
//                tap = 0;
//              });
            }
          }); */
    // TODO: implement initState    
    mapData();
    _controller.addListener(() => _extension = _controller.text);
    _getUserData();    
    trackSegment();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        checkProfile = prefs.get("profile_url");
        _translation = prefs.get("gender");                
      });
    });
    super.initState();
  }

  trackSegment() {
    Segment.track(
      eventName: 'View Profile Update',
      properties: {
        'Source': 'Native apps'
      }
    );
  }

  Future _onCameraPressed() async {
    _isLoadingSecondary = true;

    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);
    setState(() {
      _imageFile = image;
    });
    File img = await image;

    if (img != null) {
      try {
        if (_isLoadingSecondary == true) {
          showToast('Image Uploading Please wait',
              duration: 10, gravity: Toast.BOTTOM);
        }
//        FormData formData = new FormData.fromMap({"file": await MultipartFile.fromFile(img.path)});
        var dio = Dio(BaseOptions(
          connectTimeout: 10000,
        ));
        dio.interceptors.add(LogInterceptor(responseBody: true));

        Response response = await dio.post(
          'https://www.filestackapi.com/api/store/S3?key=AwqN8FPp7Soa3DU6jTSt2z',
          data: img.openRead(), // Post with Stream<List<int>>
          options: Options(
            headers: {
              HttpHeaders.userAgentHeader: "dio",
              HttpHeaders.contentTypeHeader: ContentType.text,
            },
            contentType: 'image/png',
            responseType: ResponseType.plain,
          ),
        );
        if (response.statusCode == 200) {
          _isLoadingSecondary = false;
//          print(response.data);
          var filestackresponse = jsonDecode(response.data);

          setState(() {
            checkProfile = filestackresponse['url'];
          });

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('profile_url', checkProfile);
          showToast('Image Uploaded', duration: 4, gravity: Toast.BOTTOM);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  int selectedPage;

  void mapData() async {    
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();    
    String name = sharedPreferences.getString("name");
    String gender = sharedPreferences.getString("gender");
    String address = sharedPreferences.getString("address");    
    String dob = sharedPreferences.getString("dob");
    String phone = sharedPreferences.getString("phone");
    String profile_url = sharedPreferences.getString("profile_url");
    String profile_type = sharedPreferences.getString("profiletype");

    String _checkGender = sharedPreferences.getString("gender");    
         

    print('data');    

    checkProfile = profile_url;
    profileType = profile_type;

    if (name != null) {
      nameController.text = name;
    }    

    if (address != null) {
      addressController.text = address;
    }
    if (dob != null) {
      dobController.text = dob;
    }
    if (phone != null) {
      phoneController.text = phone;
    }
    String _translationHolder =
        await translator.translate(_checkGender, to: 'en').toString();   
    if (gender != null) {
      setState(() {
        _translation = _translationHolder;
      });
    }  

//
//    nameController.text = name;
////    genderController.text = gender;
//    _selectedGender = gender;
//    addressController.text = address;
//    dobController.text = dob;
//    phoneController.text = phone;
  }

  String hasResume;
  String askForGender;
  String askForBirthDate;
  String askForProfilePick;

  Future<Null> _getUserData() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkUserAuthImage = prefs.getString("authentication_page_image");
      hasResume = prefs.getString("hasResume");  
      print('has resume $hasResume'); 
      print('gender: ${prefs.getString("askForGender")}');
      print('birth: ${prefs.getString("askForDateBirth")}');
      print('profile pic: ${prefs.getString("askForProfilePic")}');
      if (prefs.getString("askForGender") != null) {
        askForGender = prefs.getString("askForGender");        
      } else {
        askForGender = 'true';
      }
      if (prefs.getString("askForDateBirth") != null) {
        askForBirthDate = prefs.getString("askForDateBirth");
        print('birth date');
        print(askForBirthDate);
      } else {
        askForBirthDate = 'true';
      }
      if (prefs.getString("askForProfilePic") != null) {
        askForProfilePick = prefs.getString("askForProfilePic");
      }  else {
        askForProfilePick = 'true';
      } 
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Declare MediaQueryData
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    /// To Sett PhotoProfile,Name and Edit Profilex
    var _profile = Padding(
      padding: EdgeInsets.only(
        top: 185.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              askForProfilePick == 'true' ?
              Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2.5),
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
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        onTap: () {
                          _onCameraPressed();
                        },
                        child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(25)),
                            child: Icon(
                              Icons.mode_edit,
                              size: 18,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ), 
              ) : Container(),
            ],
          ),
          Container(),
        ],
      ),
    );
    Color hexToColor(String code) {
      Color color = code != null
          ? new Color(
              int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000)
          : Colors.white;
      return color;
    }

    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
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

        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                /// Setting Header Banner
                Container(
                  height: 240.0,
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: global.authentication_page_image,
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(global.authentication_page_image),
                          fit: BoxFit.cover)),
                ),

                /// Calling _profile variable
                _profile,
                Padding(
                  padding: EdgeInsets.only(top: askForProfilePick == 'true' ? 310.0 : 260),
                  child: Column(
                    /// Setting Category List
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          FilePickerDemo(hasResume),
                          hasResume != 'true' ?
                          SizedBox(width: 15) : Container(),
                          hasResume == 'true' ? 
                          SizedBox(height: 15) : Container(),
                          hasResume == 'true' ? 
                          ShowResume() : Container(),  
                        ],
                      ),                                           
                      if (docPaths != null)
                        Text(docPaths.join('\n')),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0.0, left: 30.0, right: 30.0),
                        /* child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ), */
                      ),

                      SizedBox(height: 15),

                      /// Call category class
                      textFromField(
                        icon: Icons.person_outline,
                        password: false,
                        controller: nameController,
                        email: 'Name',
                        inputType: TextInputType.text,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 85.0, right: 30.0),
                      ),
                      textFromField(
                        icon: Icons.home,
                        password: false,
                        controller: addressController,
                        email: 'Address',
                        inputType: TextInputType.text,
                      ),
                      askForGender == 'true' ?
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 85.0, right: 30.0),
//                        child: Divider(
//                          color: Colors.black12,
//                          height: 2.0,
//                        ),
                      ) : Container(height: 0.0,),    
                      askForGender == 'true' ?                  
                      genderDropDown() : Container(height: 0.0,),
                      askForBirthDate == 'true' ? 
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 85.0, right: 30.0),
                      ) : Container(height: 0.0,),
                      askForBirthDate == 'true' ? 
                      _buildDOBTextField(context) : Container(height: 0.0,),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 85.0, right: 30.0),
                      ),
                      textFromField(
                        icon: Icons.phone_iphone,
                        password: false,
                        controller: phoneController,
                        email: 'Phone',
                        inputType: TextInputType.phone,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 30.0, right: 30.0),
                        child: Divider(
                          color: Colors.black12,
                          height: 2.0,
                        ),
                      ),
                      InkWell(
                          splashColor: Colors.yellow,
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            setState(() {
                              _isLoading = true;
                            });
                            updateProfile();
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 40),
                            child: /* !_isLoading ?  */updateButton() /* : Loader() */,
                          )),

                      Padding(padding: EdgeInsets.only(bottom: 20.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
//        floatingActionButton: FloatingActionButton(
//          onPressed: _onGalleryPressed,
//          tooltip: 'Pick File',
//          child: Icon(Icons.file_upload),
//        ),
      ),
    );
  }

//
//
//  void updateProfileWithResume() async {
//      SharedPreferences sharedPreferences =
//      await SharedPreferences.getInstance();
//      String auth_token = sharedPreferences.get('token');
//
////      String profile_url = sharedPreferences.setString('profile_url');
//
//
//
//
//      String tenant = Constants.tenant;
//
////      String genderHolder = await translator.translate(_translation, to: 'es');
//
//
//    String updateProfileURL =
//        "https://www.ondemandstaffing.app/api/v1/create_or_update_jobseeker?tenant=" + tenant + "&profileType=JobSeeker&name=&profiletype=" + profileType ;
//
//
//    Map<String, String> headers = {
//        'AUTHORIZATION': auth_token,
////        "Content-Type": "application/x-www-form-urlencoded",
//      };
//
////
//      Map<String, dynamic> dataDic = {
//        'tenant': tenant,
//        'profiletype': profileType,
//      };
//      print('data');
//      print(auth_token);
////      print(dataDic);
//
//
//    try {
//      http.Response response = await http.post(updateProfileURL,
//          headers: headers , body: jsonEncode(dataDic));
//      var jsonResponse;
//      if (response.statusCode == 200) {
//        jsonResponse = jsonDecode(response.body);
//
//      print(jsonResponse);
//
////            new LoginAnimation(
////              animationController: sanimationController.view,
////            );
//        }
//
//
//    } catch (err) {
//      print("response error is: $err");
//      setState(() {
//        _isLoading = false;
//        showToast(err, duration: 4, gravity: Toast.BOTTOM);
//      });
//    }
//
//
//
//
//  }

  void updateProfile() async {
    if (validateTextFields()) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String auth_token = sharedPreferences.get('token');
//      String profile_url = sharedPreferences.setString('profile_url');
      String tenant = Constants.tenant;
      String genderHolder;
      if (askForGender == 'true') {
        genderHolder = await translator.translate(_translation, to: 'es').toString();      
        print('genderupdate');
        print(genderHolder);
        if (genderHolder == 'Masculino') {
          print('Hombre');
          genderHolder = 'Hombre';
        }
        if (genderHolder == 'Hembra') {
          print('Mujer');
          genderHolder = 'Mujer';
        }
      } 
      

      String updateProfileURL =
          "https://www.ondemandstaffing.app/api/v1/create_or_update_jobseeker?tenant=" +
              tenant +
              "&profileType=JobSeeker&name=" +
              nameController.text +
              "&contact_phone=" +
              phoneController.text +
              ((askForProfilePick == 'true') ? ("&profile_url=" +
              checkProfile) : ('')) +               
              "&date_of_birth=" +
              dobController.text +
              ((askForGender == 'true') ? ("&gender=" +
              genderHolder ) : ('')) +
              "&address=" +
              addressController.text;        

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
      print(auth_token);
//      print(dataDic);

      try {
        http.Response response =
            await http.post(updateProfileURL, headers: headers);
        var jsonResponse;
        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body);
          print('gender');
          print(jsonResponse["jobseeker"]["gender"]);
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
          var contact_phone = jsonResponse["jobseeker"]["contact_phone"].toString();
          var active = jsonResponse["jobseeker"]["active"].toString();
          var gender = jsonResponse["jobseeker"]["gender"].toString();
          var token = jsonResponse["user"]["authentication_token"].toString();
          print(token);

          _translation = await translator.translate(gender, to: 'en').toString();

          Segment.identify(userId: sharedPreferences.getString('user_id'), traits: {'email': email, 'user name' : nameController.text, 'phone' : phoneController.text});

          print('male response');
          print(_translation);

          if (_translation == 'Man') {
            _translation = 'Male';
          }
          if (_translation == 'Woman') {
            _translation = 'Female';
          }

          print('print after change');

          print(_translation);

          sharedPreferences.setString("token", token);
          sharedPreferences.setString("name", name);
          sharedPreferences.setString("gender", _translation);
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

//            print(CoordinateData);

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
//                print(jsonResponseCoordinate);
              } else {
                print(responseCoordinate.reasonPhrase);
              }
            } catch (err) {
              _isLoading = false;
//              print("response error is: $err");
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
                builder: (BuildContext context) => new JobTypePreferences()));
            
            /* Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => new AdditionalForm())); */
          } else if (widget.isFromAccountSettings != null) {
            setState(() {
              _isLoading = false;
              showToast("Updated successfully!",
                  duration: 4, gravity: Toast.BOTTOM);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => new AccountSettings()));
            });
          } else {
            setState(() {
              _isLoading = false;
              showToast("Updated successfully!",
                  duration: 4, gravity: Toast.BOTTOM);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => new JobTypePreferences()));
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

  /* Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  } */

  bool validateTextFields() {
    if (nameController.text.isEmpty) {
      showToast("Please enter name!", gravity: Toast.BOTTOM);
      return false;
    }
    if (askForGender == 'true') {
      if (_translation == "Select Gender" || _translation == null) {
      showToast("Please select gender!", gravity: Toast.BOTTOM);
      return false;
    }
    }    
    if (addressController.text.isEmpty) {
      showToast("Please enter address!", gravity: Toast.BOTTOM);
      return false;
    }
    if (askForBirthDate == 'true') {
      if (dobController.text.isEmpty) {
      showToast("Please select date of birth!", gravity: Toast.BOTTOM);
      return false;
    }
    }    
    if (phoneController.text.isEmpty) {
      showToast("Please enter phone number!", gravity: Toast.BOTTOM);
      return false;
    }
    if (askForProfilePick == 'true') {
      if (checkProfile == null) {
        showToast("Please upload image!", gravity: Toast.BOTTOM);
        return false;
      }
    }    

//    if (profileType == null){
//      showToast("Please upload file!", gravity: Toast.BOTTOM);
//      return false;
//    }

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
        child: !_isLoading ? Text(
          widget.isFromAccountSettings != null ? 'Update' : 'Next',
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

  Widget genderDropDown() {    
    if (_translation == null) {
      translationValue = 'Select Gender';
    } else {
      translationValue = _translation;
    }
    
    print('translation');
    print(_translation);
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
          Icon(
            Icons.person,
            color: Colors.black38,
          ),
          Container(
//          height: 60,
            padding: EdgeInsets.only(left: 18),
            width: MediaQuery.of(context).size.width * 0.65,
            child: DropdownButtonFormField<String>(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.white,
              ),
//              itemHeight: 60,
              isDense: true,
              isExpanded: true,
              style: TextStyle(fontSize: 16, fontFamily: 'Sans'),

              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
                labelStyle: new TextStyle(
                    fontSize: 15,
                    fontFamily: 'sans',
                    color: Colors.black38,
                    fontWeight: FontWeight.w600),
                labelText: 'Gender',
              ),
//        isExpanded: true,

              items: <String>['Select Gender', 'Male', 'Female', 'Other']
                  .map((String val) {
                    print(_translation);
                return new DropdownMenuItem<String>(
                  value: val,
                  child: Row(
                    children: <Widget>[
                      new Text(
                        val.toString(),
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
              value: (translationValue == null) ? 'Select Gender' : _translation,

//              hint: Text(
//                _selectedGender ,
////            style: TitleTheme(
////              color: isSelectedGender ? Colors.red[800] : Colors.grey[400],
////            ),
//              ),
              validator: (value) =>
                  value == null || value == 'Please select a gender'
                      ? 'Gender type required'
                      : null,
              onChanged: (newVal) {
                

//              if (newVal == 'Male'){
//                    _translation = 'hombre';
//              }
//              if (newVal == 'Female'){
//                _translation = 'mujer';
//              }                                

                FocusScope.of(context).requestFocus(FocusNode());
                setState(
                  () {
                    _translation = newVal;
                    translationValue = newVal;
                    print(_translation);
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
          child: Stack(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Positioned(
                  left: 40,
                  top: 5,
                  child: Container(
                      margin: EdgeInsets.only(top: 0),
                      child: Text(
                        'Date Of Birth',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black38,
                            fontFamily: 'sans',
                            fontWeight: FontWeight.w600),
                      ))),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: dobController,
                  decoration: InputDecoration(
                      hintText: 'Date Of Birth',
//                      hintStyle: TextStyle(color: Colors.black38,fontSize: 12),
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Sans',
                          letterSpacing: 0.3,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600),
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
            ],
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

/// Component category class to set list
class category extends StatelessWidget {
  @override
  String txt, image;
  GestureTapCallback tap;
  double padding;

  category({this.txt, this.image, this.tap, this.padding});

  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: padding),
                  child: Image.asset(
                    image,
                    height: 25.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    txt,
                    style: _txtCategory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
