import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoloc;

import 'package:full_course/models/location_data.dart';
import 'package:full_course/models/product.dart';


class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  // Uri _staticMapUri;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  GoogleMapController _mapController;
  Map<String, double> _coords;
  Set<Marker> _markers;
  LocationDataModel _locationData;
  

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getAddressCoordinates(widget.product.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getAddressCoordinates(String address, {bool geocode = false, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _coords = null;
        _markers = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final uri = Uri.https(
        'maps.googleapis.com', 
        '/maps/api/geocode/json',
        {'address': address, 'key': 'AIzaSyDV9hvQ5ziMJ1Pbys7e-vbWaQR-K6lNyRM'}
      );
      final http.Response response = await http.get(uri);
      final decodedRes = json.decode(response.body);
      final formattedAddress = decodedRes['results'][0]['formatted_address'];
      final coords = decodedRes['results'][0]['geometry']['location'];
      _locationData = LocationDataModel(lat: coords['lat'], lng: coords['lng'], address: formattedAddress);
    } else if (lat == null && lng == null){
      _locationData = widget.product.location;
    } else {
      _locationData = LocationDataModel(lat: lat, lng: lng, address: address);
    }

    widget.setLocation(_locationData);
    if (_coords != null && _mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_locationData.lat, _locationData.lng),
            zoom: 15.0
          )
        )
      );
    }

    setState(() {
      _addressInputController.text = _locationData.address;
      _markers = {
        Marker(
          markerId: MarkerId('position'),
          position: LatLng(_locationData.lat, _locationData.lng)
        )
      };
      _coords = {'lat': _locationData.lat, 'lng': _locationData.lng};
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getAddressCoordinates(_addressInputController.text);
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final uri = Uri.https(
      'maps.googleapis.com', 
      '/maps/api/geocode/json',
      {'latlng': '${lat.toString()},${lng.toString()}', 'key': 'AIzaSyDV9hvQ5ziMJ1Pbys7e-vbWaQR-K6lNyRM'}
    );
    final http.Response response = await http.get(uri);
    final decodedRes = json.decode(response.body);
    final formattedAddress = decodedRes['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geoloc.Location();
    final currentLocation = await location.getLocation();
    final address = await _getAddress(currentLocation['latitude'], currentLocation['longitude']);
    _getAddressCoordinates(address, geocode: false, lat: currentLocation['latitude'], lng: currentLocation['longitude']);
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          decoration: InputDecoration(
            labelText: 'Address'
          ),
          validator: (String value) {
            if (_locationData == null || value.isEmpty) {
              return 'No valid location found';
            }
          },
        ),
        SizedBox(height: 10.0,),
        FlatButton(
          child: Text('My location'),
          onPressed: _getUserLocation,
        ),
        SizedBox(height: 10.0,),
        _coords != null 
          ? Container(
              height: 300,
              width: 500,
              child: GoogleMap(
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                markers: _markers,
                mapType: MapType.terrain,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_coords['lat'], _coords['lng']),
                  zoom: 15.0
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
            )
          : Container()
      ],
    );
  }
}