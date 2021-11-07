import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,                  
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[                      
          /* Lottie.asset(Constants.buttonLoadingAnimation), */
          Container(
            width: 150.0,
            margin: EdgeInsets.only(bottom: 20.0),
            child: Image.asset('assets/icon/hiking.png')
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Nothing here yet!',
              style: TextStyle(
                fontFamily: "Gotik",
                fontWeight: FontWeight.w600,
                color: Colors.black54, 
                fontSize: 25.0  
              )                       
            ),
          ),
        ],
      )
    );
  }
}