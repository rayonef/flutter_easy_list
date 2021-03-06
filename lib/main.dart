import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/pages/auth.dart';
import 'package:full_course/pages/products_admin.dart';
import 'package:full_course/pages/products.dart';
import 'package:full_course/pages/product.dart';
import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/models/product.dart';
import 'package:full_course/helpers/custom_route.dart';

void main() {
  // MapView.setApiKey('AIzaSyDV9hvQ5ziMJ1Pbys7e-vbWaQR-K6lNyRM');
  runApp(MyApp());
}

class MyApp extends StatefulWidget { 
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
        ),
        // home: AuthPage(),
        routes:{ 
          // '/': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/products': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/admin': (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings setting) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => AuthPage()
            );
          }
          final List<String> pathElements = setting.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = _model.allProducts.firstWhere((Product product) => product.id ==productId);
            return CustomRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings setting) {
          return CustomRoute(
            builder: (BuildContext context) => !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          );
        },
      ),
    );
  }
}






