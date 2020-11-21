//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter @IbsanjU Maps',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IbsanjU Maps'),
    );
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
  Marker marker;
  Circle circle;
  String address;
  List<Address> addresses;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(43.6447122, -79.3825873),
    zoom: 10,
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              markers: Set.of((marker != null) ? [marker] : []),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: onTapMarker,
              onLongPress: onTapMarker,
            ),
          ),
          Positioned(
            top: 50.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 50.0,
                // maxHeight: 200.0,
                minWidth: double.infinity,
              ),
              // height: 200.0,
              // width: double.infinity,
              padding: EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.0,
                    color: Colors.grey,
                    offset: Offset(0.0, 3.0), //(x,y)
                    blurRadius: 15.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      address ?? 'Select a location on the map to get Address',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  address == null
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red)),
                              color: Colors.white,
                              textColor: Colors.red,
                              padding: EdgeInsets.all(8.0),
                              onPressed: () {
                                setState(() {
                                  addresses = null;
                                  address = null;
                                  marker = null;
                                });
                              },
                              child: Text(
                                "Reset".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red)),
                              onPressed: () {},
                              color: Colors.red,
                              textColor: Colors.white,
                              child: Text("Okay".toUpperCase(),
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        )
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 25.0,
              child: Row(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      await getUserLocation();
                    },
                    child: Icon(Icons.my_location_sharp),
                  ),
                ],
              )),
          addresses == null
              ? Container(height: 1.0, width: 1.0)
              : Positioned(
                  // top: MediaQuery.of(context).size.height - 250.0,
                  bottom: 100.0,
                  child: Container(
                    height: 125.0,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(8.0),
                        children: addresses.map((addr) {
                          return clientCard(addr);
                        }).toList()),
                  ),
                )
        ],
      ),
    );
  }

  zoomToLoc(LatLng latLng) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latLng.latitude, latLng.longitude), zoom: 15.0)));
  }

  getUserLocation() async {
    //call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'h: please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'h: permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    if (myLocation != null) {
      getAddress(Coordinates(myLocation.latitude, myLocation.longitude));
      addMarker(LatLng(myLocation.latitude, myLocation.longitude));
      zoomToLoc(LatLng(myLocation.latitude, myLocation.longitude));
    }
  }

  getAddress(Coordinates coordinates) async {
    var addrs = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    addresses = null;
    setState(() {
      addresses = addrs;
    });
    Address first = addresses.first;
    int i = 0;
    addresses.forEach((a) {
      print('\n\n\n');
      print('h:  aLine ${++i}     ${a.addressLine}');
      // printAddr(a);
    });
    print('Addresses Length h:      ${addresses.length}');
    setAddress(first);
  }

  setAddress(Address first) {
    String a = '';
    if (first != null) {
      printAddr(first);
      a = 'Address :  ';
      if (first.addressLine != null) a = a + '${first.addressLine} \n';
      if (first.locality != null) a = a + '${first.locality} ';
      if (first.postalCode != null) a = a + '${first.postalCode} ';
    }
    if (a.length > 0) {
      setState(() => address = a);
    } else {
      setState(() => address = null);
    }
  }

  onTapMarker(LatLng latLng) {
    setState(() {
      getAddress(Coordinates(latLng.latitude, latLng.longitude));
      addMarker(latLng);
      zoomToLoc(latLng);
    });
  }

  printAddr(Address l) {
    print('h: addressLine     :   ${l.addressLine}');
    print('h: adminArea       :   ${l.adminArea}');
    print('h: coordinates     :   ${l.coordinates}');
    print('h: countryCode     :   ${l.countryCode}');
    print('h: countryName     :   ${l.countryName}');
    print('h: featureName     :   ${l.featureName}');
    print('h: locality        :   ${l.locality}');
    print('h: postalCode      :   ${l.postalCode}');
    print('h: subAdminArea    :   ${l.subAdminArea}');
    print('h: subLocality     :   ${l.subLocality}');
    print('h: subThoroughfare :   ${l.subThoroughfare}');
    print('h: thoroughfare    :   ${l.thoroughfare}');
  }

  addMarker(LatLng latLng) {
    this.setState(() {
      marker = Marker(
          visible: true,
          markerId: MarkerId("home"),
          position: latLng,
          draggable: false,
          zIndex: 1,
          flat: false,
          infoWindow: InfoWindow(title: 'Selected location'));
    });
  }

  Widget clientCard(Address client) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: InkWell(
            onTap: () {
              setState(() {
                setAddress(client);
                addMarker(LatLng(
                    client.coordinates.latitude, client.coordinates.longitude));
                zoomToLoc(LatLng(
                    client.coordinates.latitude, client.coordinates.longitude));
              });
            },
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(18.0),
              child: Container(
                  padding: EdgeInsets.all(8.0),
                  height: 200.0,
                  width: 250.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white),
                  child: Center(child: Text(client.addressLine))),
            )));
  }
}
