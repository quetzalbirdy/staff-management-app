import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:wolf_jobs/Library/app-localizations.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
import 'package:wolf_jobs/UI/AcountUIComponent/filePicker.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/HomePage.dart';
import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/Login.dart';
import 'package:http/http.dart';
import 'package:wolf_jobs/globals.dart' as global;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/constant.dart' as Constants;

import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:wolf_jobs/resources/pusher_service.dart';

import 'UI/OnBoarding.dart';

/// Run first apps open
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Segment.setContext({
    'device': {
      'token': 'testing',
    }
  });
  runApp(EasyLocalization(child: myApp()));
}

/// Set orienttation
class myApp extends StatefulWidget {
  @override
  _myAppState createState() => _myAppState();
}

class _myAppState extends State<myApp> {  

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;

    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return EasyLocalizationProvider(
        data: data,
        child: BackGestureWidthTheme(
          backGestureWidth: BackGestureWidth.fraction(1 / 2),
          child: OverlaySupport(
            child: new MaterialApp(
              title: "Wolf Jobs",            
              theme: ThemeData(
                /* canvasColor: Colors.transparent, */
                  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
                  pageTransitionsTheme: PageTransitionsTheme(
                    builders: {
                      // for Android - default page transition
                      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),

                      // for iOS - one which considers ancestor BackGestureWidthTheme
                      TargetPlatform.iOS:
                          CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
                    },
                  ),
                  brightness: Brightness.light,
                  backgroundColor: Colors.white,
                  primaryColorLight: Colors.white,
                  primaryColorBrightness: Brightness.light,
                  primaryColor: Colors.white),
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,              
                GlobalWidgetsLocalizations.delegate,
                EasyLocalizationDelegate(
                  locale: data.locale,
                  path: 'assets/language',
                )
              ],
              supportedLocales: [
                Locale('en', 'US'),
                /* Locale('zh', 'HK'),
                Locale('ar', 'DZ'),
                Locale('hi', 'IN'),
                Locale('id', 'ID') */
              ],
//            locale: data.savedLocale,
            ),
          ),
        ));
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {
  /// Check user
  bool _checkUser = false;
  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = true;

  SharedPreferences prefs;
  String brand_name;
  String logo;

  Future<Null> _checkIfUser() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    this.setState(() {
      if (prefs.getString("token") != null) {
        print('false');
        _checkUser = true;
      } else {
        print('true');
        _checkUser = false;
      }

      setState(() {
        brand_name = prefs.getString("brand_name");
        logo = prefs.getString("logo");
      });
    });
  }

  /* @override */

  getTenant() async {
    await HttpRequests().getTenant();
    startTime();
  }

  /// Setting duration in splash screen
  startTime() async {        
    return new Timer(Duration(milliseconds: 2000), navigatorPage);
  }  

  /// To navigate layout change
  void navigatorPage() async {
    print("user check  $_checkUser");
    if (_checkUser) {
      /// if userhas never been login
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (_, __, ___) => HomePage()));
    } else {
      /// if userhas ever been login
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (_, __, ___) => OnBoarding(
            onboardingTitle1: sharedPreferences.getString('onboardingTitle1'),
            onboardingTitle2: sharedPreferences.getString('onboardingTitle2'),
            onboardingTitle3: sharedPreferences.getString('onboardingTitle3'),
            onboardingDesc1: sharedPreferences.getString('onboardingDesc1'),
            onboardingDesc2: sharedPreferences.getString('onboardingDesc2'),
            onboardingDesc3: sharedPreferences.getString('onboardingDesc3')
          )));
    }
  }

  /// Declare startTime to InitState
  @override
  void initState() {
    super.initState();  
    getTenant();   
    _checkIfUser();                   
    OneSignal.shared.init(Constants.oneSignalAppId, iOSSettings: {
      OSiOSSettings.autoPrompt: false,
    });
  }    

  String onboardingTitle1;
  String onboardingDesc1;
  String onboardingTitle2;
  String onboardingDesc2;
  String onboardingTitle3;
  String onboardingDesc3;  

  Color hexToColor(String code) {
    Color color = code != null ? new Color(int.parse(code.trim().substring(1, 7), radix: 16) + 0xFF000000) : Colors.white;
    return color;
  }
  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(        
        backgroundColor: Colors.black,
        body: Container(
          /// Set Background image in splash screen layout (Click to open code)
          decoration: BoxDecoration(
//              image: DecorationImage(
//                  image: AssetImage('assets/img/man.png'), fit: BoxFit.cover)

              ),
          child: Container(
            /// Set gradient black in image splash screen (Click to open code)
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)],
                  begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter)

//                gradient: LinearGradient(
//                    colors: [
//                      hexToColor('#03305B'),
//                  hexToColor('#024648')
//                ],
//                    begin: FractionalOffset.topCenter,
//                    end: FractionalOffset.bottomCenter)
        ),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                      ),

                      /// Text header "Welcome To" (Click to open code)

                      Container(
                        padding: EdgeInsets.only(top: 15,bottom: 15,right: 5,left: 5),
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            logo !=null ?
                            CachedNetworkImage(
                              imageUrl: logo,
                              width: 120,height: 50,
                            ):
//                            Image.network(
//                              logo  , width: 220,height: 50,
//                            ):
                            Center(child: CircularProgressIndicator(),),

                            /// Animation text Treva Shop to choose Login with Hero Animation (Click to open code)


                          ],
                        ),
                      ),

                      Hero(
                        tag: "Treva",
                        child: Text(
                          brand_name != null ? brand_name : '',
                          style: TextStyle(
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 25.0,
                            letterSpacing: 0.4,
                            color: Colors.white,
                          ),
                        ),
                      )


//                      Text(
//                        brand_name != null ? brand_name : '',
//                        style: TextStyle(
//                          color: Colors.white,
//                          fontWeight: FontWeight.w200,
//                          fontFamily: "Sans",
//                          fontSize: 19.0,
//                        ),
//                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
