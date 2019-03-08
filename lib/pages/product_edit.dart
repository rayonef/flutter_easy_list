import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/models/product.dart';
import 'package:full_course/models/location_data.dart';
import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/widgets/form_inputs/location.dart';
import 'package:full_course/widgets/form_inputs/image.dart';

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
    'imageUrl': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey =GlobalKey<FormState>();
  final _titleTextController = TextEditingController();

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
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title'
      ),
      controller: _titleTextController,
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

  void _setLocation(LocationDataModel location) {
    _formData['location'] = location;
  }

  void _setImage(File image) {
    _formData['imageUrl'] = image;
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
                height: 10.0,
              ),
              LocationInput(_setLocation, product),
              SizedBox(
                height: 10.0,
              ),
              ImageInput(_setImage, product),
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
    if (!_formKey.currentState.validate() || 
        (_formData['imageUrl'] == null && model.selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (model.selectedProductIndex == -1) {
      model.addProduct(_titleTextController.text, _formData['description'], _formData['imageUrl'], _formData['price'], _formData['location'])
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
      model.updateProduct(_titleTextController.text, _formData['description'], _formData['imageUrl'], _formData['price'], _formData['location'])
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