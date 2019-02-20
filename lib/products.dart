import 'package:flutter/material.dart';

import 'package:full_course/pages/product.dart';

class Products extends StatelessWidget {
  final List<Map<String, String>> products;
  final Function deleteProduct;

  Products(this.products, {this.deleteProduct});

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
          child: Column(
            children: <Widget>[
              Image.asset(products[index]['imageUrl']),
              Text(products[index]['title']),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text('Details'),
                    onPressed: () => Navigator.pushNamed<bool>(
                      context, '/product/$index'
                    ).then((bool value) {
                      if (value) deleteProduct(index);
                    }),
                  )
                ],
              )
            ],
          ),
        );
  }

  Widget _buildProductList() {
    Widget productCard = Center(child: Text('No products found, please add some'));
    if (products.length > 0) {
      productCard = ListView.builder(
        itemBuilder: _buildProductItem,
        itemCount: products.length,
      );
    }
    return productCard;
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductList();
  }
}