import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': true
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController =TextEditingController();
  AuthMode _authMode =AuthMode.Login;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -2.0),
      end: Offset.zero
    ).animate(CurvedAnimation(
      parent:_controller,
      curve: Curves.fastOutSlowIn
    ));
    super.initState();
  }

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
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Email'
      ),
      validator: (String value) {
        if (value.isEmpty || !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      initialValue: _formData['email'],
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Password',
      ),
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Invalid pasword';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirm() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Confirm Password',
          ),
          validator: (String value) {
            if (_passwordController.text != value && _authMode == AuthMode.Signup) {
              return 'Passwords do not match';
            }
          },
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept terms'),
    );
  }

  void _submitForm(MainModel model) async {
    if (!_formKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _formKey.currentState.save();
    print(_formData);
    final Map<String, dynamic> authAttempt = await model.authenticate(_formData['email'], _formData['password'], _authMode);

    if (authAttempt['success']) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An error Occurred!'),
            content: Text(authAttempt['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }
    
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmail(),
                    SizedBox(height: 10.0,),
                    _buildPassword(),
                    SizedBox(height: 10.0,),
                    _buildPasswordConfirm(),
                    _buildAcceptSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    FlatButton(
                      child: Text('Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        if (_authMode == AuthMode.Login) {
                          setState(() {
                            _authMode =AuthMode.Signup;
                          });
                          _controller.forward();
                        } else {
                          setState(() {
                            _authMode =AuthMode.Login;
                          });
                          _controller.reverse();
                        }
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child, MainModel model) {
                        return model.isLoading 
                        ? Center(child: CircularProgressIndicator(),)
                        : RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text('${_authMode == AuthMode.Login ? 'Login' : 'Signup'}'),
                          onPressed: () => _submitForm(model),
                        );
                      },
                    )
                  ]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}