
import 'package:wolf_jobs/model/JobListHolder.dart';
import 'package:wolf_jobs/model/ShiftListHolder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapShiftPage extends StatefulWidget {

  final JobListHolder joblistHolder;
  MapShiftPage(this.joblistHolder);

  @override
  _MapShiftPageState createState() => _MapShiftPageState();
}

class _MapShiftPageState extends State<MapShiftPage> {
  List<Marker> allMarkers = [];

  GoogleMapController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(widget.joblistHolder.shifts[0].latitude, widget.joblistHolder.shifts[0].longitude)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF488BEC),
        centerTitle: true,
        elevation: 0.0,
        title: new Text(
          widget.joblistHolder.shifts[0].address,
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
              CameraPosition(target: LatLng(widget.joblistHolder.shifts[0].latitude,  widget.joblistHolder.shifts[0].longitude), bearing: 15.0,
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