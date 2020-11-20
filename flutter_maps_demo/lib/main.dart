import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.amber,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: MyHomePage(title: 'IbsanjU Maps Demo'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //
  GoogleMapController _mapController;
  String searchAddr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: Text(widget.title)),
        body: Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition:
              CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 10.0),
        ),
        Positioned(
          top: 50.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Address',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 35.0,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }

  void onMapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }
}
