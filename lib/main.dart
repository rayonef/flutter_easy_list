import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/pages/auth.dart';
import 'package:full_course/pages/products_admin.dart';
import 'package:full_course/pages/products.dart';
import 'package:full_course/pages/product.dart';
import 'package:full_course/scoped-models/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget { 
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  

  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
        ),
        // home: AuthPage(),
        routes:{ 
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => ProductsPage(model),
          '/admin': (BuildContext context) => ProductsAdminPage(),
        },
        onGenerateRoute: (RouteSettings setting) {
          final List<String> pathElements = setting.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductPage(index),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings setting) {
          return MaterialPageRoute(
            builder: (BuildContext context) => ProductsPage(model),
          );
        },
      ),
    );
  }
}






