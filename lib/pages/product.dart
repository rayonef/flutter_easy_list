import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/widgets/ui_elements/title_default.dart';
import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/models/product.dart';


class ProductPage extends StatelessWidget {
  final int index;

  ProductPage(this.index);

  Widget _buildAddressPriceRow(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Union Square, San Fancisco',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          )
        ),
        Text(
          '\$${product.price.toString()}',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          final Product product = model.allProducts[index];
          return Scaffold(
            appBar: AppBar(
              title: Text(product.title),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.network(product.imageUrl),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TitleDefault(product.title),
                ),
                _buildAddressPriceRow(product),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                  )
                )
              ],
            ),
          );
        },
      ) 
    );
  }
}