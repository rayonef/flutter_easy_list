import 'package:flutter/material.dart';

import 'package:full_course/widgets/products/price_tag.dart';
import 'package:full_course/widgets/ui_elements/title_default.dart';
import 'package:full_course/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product.title),
          SizedBox(width: 8.0),
          PriceTag(product.price.toString())
        ],
      )
    );
  }

  Widget _buildAdress() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0
        ),
        borderRadius: BorderRadius.circular(4.0)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 2.5
        ),
        child: Text('Union Square, San Fancisco'),
      )
    );
  }

  Widget _buildActions(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Theme.of(context).accentColor,
          onPressed: () => Navigator.pushNamed<bool>(
            context, '/product/${productIndex.toString()}'
          ),
        ),
        IconButton(
          icon: Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () => {},
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
          child: Column(
            children: <Widget>[
              Image.asset(product.imageUrl),
              _buildTitlePriceRow(),
              _buildAdress(),
              _buildActions(context)
            ],
          ),
        );
  }
}