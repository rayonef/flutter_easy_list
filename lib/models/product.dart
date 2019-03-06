import 'package:flutter/material.dart';

import 'package:full_course/models/location_data.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final LocationDataModel location;

  Product({
    @required this.id,
    @required this.title, 
    @required this.description,
    @required this.price, 
    @required this.imageUrl,
    @required this.userEmail,
    @required this.userId,
    @required this.location,
    this.isFavorite = false
  });

  
}