import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String _email;
  String _password;
  bool _termsAccepted = false;

  DecorationImage _buildBgImg() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.dstATop
      ),
      image: AssetImage('assets/background.jpg')
    );
  }

  Widget _buildEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Email'
      ),
      onChanged: (String value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget _buildPassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Password',
      ),
      onChanged: (String value) {
        setState(() {
          _password = value;
        });
      },
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _termsAccepted,
      onChanged: (bool value) {
        setState(() {
          _termsAccepted = value;
        });
      },
      title: Text('Accept terms'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Easy List'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBgImg()
        ),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Column(
                children: <Widget>[
                  _buildEmail(),
                  SizedBox(height: 10.0,),
                  _buildPassword(),
                  _buildAcceptSwitch(),
                  SizedBox(
                    height: 15.0,
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text('Login'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/products');
                    },
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}