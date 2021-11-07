import 'package:wolf_jobs/resources/httpRequests.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolf_jobs/Library/intro_views_flutter-2.4.0/lib/Models/page_view_model.dart';
import 'package:wolf_jobs/Library/intro_views_flutter-2.4.0/lib/intro_views_flutter.dart';
import 'package:wolf_jobs/UI/LoginOrSignup/ChoseLoginOrSignup.dart';

import 'LoginOrSignup/Login.dart';

class OnBoarding extends StatefulWidget {
  final onboardingTitle1;
  final onboardingTitle2;
  final onboardingTitle3;
  final onboardingDesc1;
  final onboardingDesc2;
  final onboardingDesc3;
  OnBoarding({Key key, this.onboardingTitle1, this.onboardingTitle2, this.onboardingTitle3, this.onboardingDesc1, this.onboardingDesc2, this.onboardingDesc3}): super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {

  @override
  void initState() {
    super.initState();  
    getOnboarding();    
  }

  getOnboarding() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await HttpRequests().getTenant();
    newOnboardingTitle1 = sharedPreferences.getString('onboardingTitle1');
    newOnboardingTitle2 = sharedPreferences.getString('onboardingTitle2') ;
    newOnboardingTitle3 = sharedPreferences.getString('onboardingTitle3');
    newOnboardingDesc1 = sharedPreferences.getString('onboardingDesc1');
    newOnboardingDesc2 = sharedPreferences.getString('onboardingDesc2');
    newOnboardingDesc3 = sharedPreferences.getString('onboardingDesc3');
  }

  var newOnboardingTitle1;
  var newOnboardingTitle2;
  var newOnboardingTitle3;
  var newOnboardingDesc1;
  var newOnboardingDesc2;
  var newOnboardingDesc3;
  
  static const _fontHeaderStyle = TextStyle(
    fontFamily: "Popins",
    fontSize: 21.0,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
    letterSpacing: 1.5,
    
  );

  static const _fontDescriptionStyle = TextStyle(
    fontFamily: "Sans",
    fontSize: 15.0,
    color: Colors.black26,
    fontWeight: FontWeight.w400
  );    

  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      [
        new PageViewModel(
          pageColor:  Colors.white,
          iconColor: Colors.black,
          bubbleBackgroundColor: Colors.black,
          title: Text(
            widget.onboardingTitle1 != null ? widget.onboardingTitle1 : newOnboardingTitle1 != null ? newOnboardingTitle1 : '' ,style: _fontHeaderStyle, textAlign: TextAlign.center,
          ),
          body: Container(
            height: 250.0,
            child: Text(
              widget.onboardingDesc1 != null ? widget.onboardingDesc1 : newOnboardingDesc1 != null ? newOnboardingDesc1 : ''  ,textAlign: TextAlign.center,
              style: _fontDescriptionStyle
            ),
          ),
          mainImage: Image.asset(
            'assets/img/step-1.png',
            height: 285.0,
            width: 285.0,
            alignment: Alignment.center,
          )),

      new PageViewModel(
          pageColor:  Colors.white,
          iconColor: Colors.black,
          bubbleBackgroundColor: Colors.black,
          title: Text(
            widget.onboardingTitle2 != null ? widget.onboardingTitle2 : newOnboardingTitle2 != null ? newOnboardingTitle2 : ''  ,style: _fontHeaderStyle, textAlign: TextAlign.center,
          ),
          body: Container(
            height: 250.0,
            child: Text(
                widget.onboardingDesc2 != null ? widget.onboardingDesc2 : newOnboardingDesc2 != null ? newOnboardingDesc2 : '' 
                ,textAlign: TextAlign.center,
                style: _fontDescriptionStyle
            ),
          ),
          mainImage: Image.asset(
            'assets/img/step-2.png',
            height: 285.0,
            width: 285.0,
            alignment: Alignment.center,
          )),

      new PageViewModel(
          pageColor:  Colors.white,
          iconColor: Colors.black,
          bubbleBackgroundColor: Colors.black,
          title: Text(
            widget.onboardingTitle3 != null ? widget.onboardingTitle3 : newOnboardingTitle3 != null ? newOnboardingTitle3 : ''  ,style: _fontHeaderStyle, textAlign: TextAlign.center
          ),
          body: Container(
            height: 250.0,
            child: Text(
                widget.onboardingDesc3 != null ? widget.onboardingDesc3 : newOnboardingDesc3 != null ? newOnboardingDesc3 : ''  ,textAlign: TextAlign.center,
                style: _fontDescriptionStyle
            ),
          ),
          mainImage: Image.asset(
            'assets/img/step-3.png',
            height: 285.0,
            width: 285.0,
            alignment: Alignment.center,
          )),
      ],
      pageButtonsColor: Colors.black45,
      skipText: Text("SKIP",style: _fontDescriptionStyle.copyWith(color: Colors.deepPurpleAccent,fontWeight: FontWeight.w800,letterSpacing: 1.0),),
      doneText: Text("DONE",style: _fontDescriptionStyle.copyWith(color: Colors.deepPurpleAccent,fontWeight: FontWeight.w800,letterSpacing: 1.0),),
      onTapDoneButton: ()async {

     SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
       prefs.setString("username", "Login");
        Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_,__,___)=> new LoginScreen(),
//        transitionsBuilder: (_,Animation<double> animation,__,Widget widget){
//          return Opacity(
//            opacity: animation.value,
//            child: widget,
//          );
//        },
//        transitionDuration: Duration(milliseconds: 1500),
        ));
      },
    );
  }
}

