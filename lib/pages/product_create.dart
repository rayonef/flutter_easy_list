import 'package:flutter/material.dart';

class ProductCreatePage extends StatefulWidget {
  final Function addProduct;

  ProductCreatePage(this.addProduct);

  @override
  State<StatefulWidget> createState() {
    return _ProductCreatePageState();
  }
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  String _title = '';
  String _description = '';
  double _price = 0.0;

  Widget _buildTitle() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Product Title'
      ),
      onChanged: (String value) {
        setState(() {
          _title = value;
        });
      },
    );
  }

  Widget _buildDescription() {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description'
      ),
      onChanged: (String value) {
        setState(() {
          _description = value;
        });
      },
    );
  }

  Widget _buildPrice() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Product Price'
      ),
      onChanged: (String value) {
        setState(() {
          _price = double.parse(value);
        });
      },
    );
  }

  void _submitForm() {
    final Map<String, dynamic> product = {
      'title': _title,
      'description': _description,
      'price': _price,
      'imageUrl': 'assets/food.jpg'
    };
    widget.addProduct(product);
    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          _buildTitle(),
          _buildDescription(),
          _buildPrice(),
          SizedBox(
            height: 15.0,
          ),
          RaisedButton(
            child: Text('Save'),
            textColor: Colors.white,
            color: Theme.of(context).accentColor,
            onPressed: _submitForm,
          )
        ],
      ),
    );
  }
}