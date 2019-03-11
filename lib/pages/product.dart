import 'package:flutter/material.dart';
import 'dart:async';

import 'package:full_course/widgets/ui_elements/title_default.dart';
import 'package:full_course/widgets/products/product_fab.dart';
import 'package:full_course/models/product.dart';
import 'package:full_course/pages/map.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  Widget _buildAddressPriceRow(Product product, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Text(
            product.location.address,
            style: TextStyle(
              fontFamily: 'Oswald',
              color: Colors.grey
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => ProductMapPage(product))
            );
          }
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
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(product.title),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(product.title),
                background: Hero(
                  tag: product.id,
                  child: FadeInImage(
                    image: NetworkImage(product.imageUrl),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/food.jpg'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      alignment: Alignment.center,
                      child: TitleDefault(product.title),
                    ),
                    _buildAddressPriceRow(product, context),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        product.description,
                        textAlign: TextAlign.center,
                      )
                    )
                  ],
                ),
              ]),
            )
          ],
        ) ,
        floatingActionButton: ProductFab(product),
      ), 
    );
  }
}