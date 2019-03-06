import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:full_course/models/product.dart';

class ProductMapPage extends StatelessWidget {
  final Product product;

  ProductMapPage(this.product);

  @override
  Widget build(BuildContext context) {
    final _markers = {
      Marker(
        markerId: MarkerId('position'),
        position: LatLng(product.location.lat, product.location.lng)
      )
    };
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: GoogleMap(
          markers: _markers,
          mapType: MapType.terrain,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(product.location.lat, product.location.lng),
            zoom: 15.0
          ),
        ),
      ),
    );
  }
}