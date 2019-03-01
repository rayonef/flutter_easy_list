import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/widgets/products/price_tag.dart';
import 'package:full_course/widgets/ui_elements/title_default.dart';
import 'package:full_course/models/product.dart';
import 'package:full_course/scoped-models/main.dart';


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

  Widget _buildAddress() {
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
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return IconButton(
              icon: Icon(model.allProducts[productIndex].isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(productIndex);
                model.toggleFavorite();
              },
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(product.imageUrl),
          _buildTitlePriceRow(),
          _buildAddress(),
          Text(product.userEmail),
          _buildActions(context)
        ],
      ),
    );
  }
}