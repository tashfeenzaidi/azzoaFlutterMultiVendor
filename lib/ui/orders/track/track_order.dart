import 'dart:async';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/ui/orders/track/map_request.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class TrackOrderPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String trackingNumber;

  TrackOrderPage({
    @required this.latitude,
    @required this.longitude,
    @required this.trackingNumber,
  });

  @override
  _TrackOrderPageState createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  bool isLoading = false;
  GoogleMapController mapController;
  LatLng myLocation;
  LatLng deliveryManLocation;
  Marker myLocationMarker;
  Marker deliveryManMarker;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  Set<Polyline> get polyLines => _polyLines;

  DatabaseReference _deliveryManPositionRef;
  StreamSubscription<Event> _deliveryManPositionSubscription;
  DatabaseError _error;
  AppConfigNotifier appConfigNotifier;

  @override
  void initState() {
    _deliveryManPositionRef = FirebaseDatabase.instance
        .reference()
        .child("azzoa")
        .child("order_tracking")
        .child(widget.trackingNumber);

    _deliveryManPositionRef.keepSynced(true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _deliveryManPositionSubscription.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );

    _deliveryManPositionSubscription =
        _deliveryManPositionRef.onValue.listen((Event event) {
      deliveryManLocation = LatLng(
        double.parse(
          event.snapshot.value["latitude"] as String,
        ),
        double.parse(
          event.snapshot.value["longitude"] as String,
        ),
      );

      sendRequest(deliveryManLocation);

      deliveryManMarker = Marker(
        markerId: MarkerId("delivery_man"),
        position: deliveryManLocation,
        infoWindow: InfoWindow(
          title: getString('track_order_delivery_man'),
        ),
      );

      setState(() {
        _error = null;
        _markers.clear();
        _markers.add(myLocationMarker);
        _markers.add(deliveryManMarker);
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
        _markers.clear();
        _markers.add(myLocationMarker);
      });
    });

    myLocation = LatLng(
      widget.latitude,
      widget.longitude,
    );

    myLocationMarker = Marker(
      markerId: MarkerId("my_location"),
      position: myLocation,
      infoWindow: InfoWindow(
        title: getString('track_order_my_location'),
      ),
    );

    _markers.add(myLocationMarker);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void sendRequest(LatLng destination) async {
    String route = await _googleMapsServices.getRouteCoordinates(myLocation,
        destination, appConfigNotifier.appConfig.apiKey.directionApiKey);
    createRoute(route);
  }

  void createRoute(String encodedPolyLines) {
    if (this.mounted &&
        encodedPolyLines != null &&
        encodedPolyLines.isNotEmpty) {
      this.setState(() {
        _polyLines.clear();
        _polyLines.add(
          Polyline(
            polylineId: PolylineId(
              myLocation.toString(),
            ),
            width: 4,
            points: _convertToLatLng(
              _decodePolyLine(encodedPolyLines),
            ),
            color: Colors.red,
          ),
        );
      });
    }
  }

  List _decodePolyLine(String polyLine) {
    var list = polyLine.codeUnits;
    var lList = new List();
    int index = 0;
    int len = polyLine.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: kCommonBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('track_order_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: kCommonBackgroundColor,
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: myLocation,
        zoom: 11.0,
      ),
      polylines: polyLines,
      markers: _markers,
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
