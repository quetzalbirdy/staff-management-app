import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
//import 'package:wolf_jobs/UI/BrandUIComponent/BrandLayout.dart';
//import 'package:wolf_jobs/UI/CartUIComponent/CartLayout.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/Home.dart';
//import 'package:wolf_jobs/UI/AcountUIComponent/Profile.dart';
import 'package:wolf_jobs/UI/HomeUIComponent/jobs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class bottomNavigationBar extends StatefulWidget {
 @override
 _bottomNavigationBarState createState() => _bottomNavigationBarState();
}



class _bottomNavigationBarState extends State<bottomNavigationBar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getEmail();
  }


  bool _checkUser = false;
  SharedPreferences prefs;
  String _checkUserName;
  Future<Null>  _getEmail() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString("token") != null) {
        print('woo');
        _checkUser = true;
      }
      _checkUserName = prefs.getString("email");
    });
  }
 int currentIndex = 0;
 /// Set a type current number a layout class
 Widget callPage(int current) {
  switch (current) {
   case 0:
    return new Menu();
   case 1:
    return new Job();
   case 2:
    return new Menu();
   case 3:
//    return new profil();
    break;
   default:
    return Menu();
  }
 }

 /// Build BottomNavigationBar Widget
 @override
 Widget build(BuildContext context) {
        var data = EasyLocalizationProvider.of(context).data;
  return EasyLocalizationProvider(
          data: data,
      child: Scaffold(
     body: callPage(currentIndex),
     bottomNavigationBar: Theme(
         data: Theme.of(context).copyWith(
             canvasColor: Colors.white,
             textTheme: Theme.of(context).textTheme.copyWith(
                 caption: TextStyle(color: Colors.black26.withOpacity(0.15)))),
         child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          fixedColor: Color(0xFF6991C7),
          onTap: (value) {
           currentIndex = value;
           setState(() {});
          },
          items: [
           BottomNavigationBarItem(
               icon: Icon(
                Icons.home,
                size: 23.0,
               ),
               title: Text(
                'home',
                style: TextStyle(fontFamily: "Berlin", letterSpacing: 0, fontSize: 12),
               )),
           BottomNavigationBarItem(
               icon: Icon(Icons.shop),
               title: Text(
                 'View Jobs',
                style: TextStyle(fontFamily: "Berlin", letterSpacing: 0, fontSize: 12),
               )),
           BottomNavigationBarItem(
               icon: Icon(Icons.shopping_cart),
               title: Text(
                'Assigned jobs',
                style: TextStyle(fontFamily: "Berlin", letterSpacing: 0, fontSize: 12),
               )),
//           BottomNavigationBarItem(
//               icon: Icon(
//                Icons.person,
//                size: 24.0,
//               ),
//               title: Text(
//                 AppLocalizations.of(context).tr('account'),
//                style: TextStyle(fontFamily: "Berlin", letterSpacing: 0.5),
//               )),
          ],
         )
     ),
    ),
  );
 }
}

