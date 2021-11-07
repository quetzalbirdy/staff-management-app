
import 'package:wolf_jobs/model/PendingShiftsHolder.dart';
import 'package:wolf_jobs/model/ShiftListHolder.dart';
import 'package:flutter/material.dart';
/* import 'package:geolocator/geolocator.dart'; */
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MapPage extends StatefulWidget {

  final ShiftListHolder shiftListHolder;
  final PendingShiftsHolder pendingShiftsHolder;
  final List<dynamic> addressCoord;
  MapPage({this.shiftListHolder, this.pendingShiftsHolder, this.addressCoord});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> allMarkers = [];

  GoogleMapController _controller;
  dynamic listHolder;
  var latitude;
  var longitude;


  @override
  void initState() {
    // TODO: implement initState
    print(widget.addressCoord);
    super.initState();
    if (widget.pendingShiftsHolder != null) {
      listHolder = widget.pendingShiftsHolder;  
      latitude = widget.pendingShiftsHolder.shift.latitude;
      longitude = widget.pendingShiftsHolder.shift.latitude;    
    } else if (widget.shiftListHolder != null) {
      listHolder = widget.shiftListHolder;
      latitude = widget.shiftListHolder.latitude;
      longitude = widget.shiftListHolder.longitude;
    }
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(latitude, longitude)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigation),
            onPressed: () {
              MapsLauncher.launchCoordinates(latitude, longitude);
            },
          ),
        ],
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF488BEC),
        centerTitle: true,
        elevation: 0.0,
        title: new Text(
          listHolder.address,
          style: TextStyle(
              color: Colors.white, fontFamily: 'Gotik', fontSize: 16.0),
        ),
//              actions: <Widget>[
//                new IconButton(icon: new Image.asset('images/JASON-LOGO-FINAL-4.png'),
//                    onPressed: (){})
//              ],
      ),

      body: Stack(
          children: [Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: GoogleMap(
              initialCameraPosition:
              CameraPosition(target: LatLng(latitude, longitude), bearing: 15.0,
                  tilt: 15.0, zoom: 18.0),
              markers: Set.from(allMarkers),
              onMapCreated: mapCreated,
            ),
          ),

          ]
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  movetoBoston() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(42.3601, -71.0589),
          zoom: 15.0,
          bearing: 45.0,
          tilt: 45.0),
    ));
  }

  movetoNewYork() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 15.0),
    ));
  }
}