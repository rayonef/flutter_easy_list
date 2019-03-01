import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/widgets/products/product_card.dart';
import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/models/product.dart';


class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products) {
    Widget productCard = Center(child: Text('No products found, please add some'));
    if (products.length > 0) {
      productCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) => ProductCard(products[index], index),
        itemCount: products.length,
      );
    }
    return productCard;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildProductList(model.displayedProducts);
      }
    );
    
  }
}