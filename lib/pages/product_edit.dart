import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/models/product.dart';
import 'package:full_course/scoped-models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'imageUrl': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey =GlobalKey<FormState>();

  Widget _buildSubmitButton(MainModel model) {
    return model.isLoading 
      ? Center(child: CircularProgressIndicator()) 
      : RaisedButton(
        child: Text('Save'),
        textColor: Colors.white,
        color: Theme.of(context).accentColor,
        onPressed: () => _submitForm(model)
      );
  }

  Widget _buildTitle(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title'
      ),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ chars long';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescription(Product product) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description'
      ),
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ chars long';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPrice(Product product) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Product Price'
      ),
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty || !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number';
        }
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  Widget _buildPageContent(BuildContext context, MainModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    final Product product = model.selectedProduct;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitle(product),
              _buildDescription(product),
              _buildPrice(product),
              SizedBox(
                height: 15.0,
              ),
              _buildSubmitButton(model)
            ],
          ),
        ),
      ),
    );
  }
  void _submitForm(MainModel model) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (model.selectedProductIndex == -1) {
      model.addProduct(_formData['title'], _formData['description'], _formData['imageUrl'], _formData['price'])
        .then((bool success) {
          if (!success) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again'),
                  actions: <Widget> [
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ]
                );
              }
            );
            return;
          }
          Navigator.pushReplacementNamed(context, '/products')
            .then((_) {
              model.selectProduct(null);
            });
        }).catchError((_) {
          
        });
    } else {
      model.updateProduct(_formData['title'], _formData['description'], _formData['imageUrl'], _formData['price'])
        .then((_) {
          Navigator.pushReplacementNamed(context, '/products')
            .then((_) {
              model.selectProduct(null);
            });
        });
    }
    
    
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent = _buildPageContent(context, model);
        return model.selectedProductIndex == -1 
          ? pageContent
          :Scaffold(
            appBar: AppBar(
              title: Text('Edit Product'),
            ),
            body: pageContent,
          );
      },
    );
  }
}