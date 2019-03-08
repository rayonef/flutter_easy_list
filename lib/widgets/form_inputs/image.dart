import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:full_course/models/product.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;

  ImageInput(this.setImage, this.product);

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _image;

  void _getImage(BuildContext context, ImageSource source) async {
    final File image = await ImagePicker.pickImage(
      source: source,
      maxWidth: 400.0,
    );
    setState(() {
      _image = image;
    });
    widget.setImage(image);
    Navigator.pop(context);
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    iconSize: 42.0,
                    icon: Icon(Icons.camera_alt),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _getImage(context, ImageSource.camera);
                    },
                  ),
                  IconButton(
                    iconSize: 42.0,
                    icon: Icon(Icons.photo_album),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _getImage(context, ImageSource.gallery);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).primaryColor;

    Widget previewImage = Text('Please select an image');
    if (_image != null) {
      previewImage = Image.file(
        _image,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      previewImage = Image.network(
        widget.product.imageUrl,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    }

    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2.0
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: buttonColor,
              ),
              SizedBox(width: 5.0,),
              Text(
                'Add image', 
                style: TextStyle(
                  color: buttonColor
                )
              )
            ],
          ),
          onPressed: () {
            _openImagePicker(context);
          },
        ),
        SizedBox(height: 10.0,),
        previewImage 
      ],
    );
  }
}