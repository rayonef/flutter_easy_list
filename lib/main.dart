import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/pages/auth.dart';
import 'package:full_course/pages/products_admin.dart';
import 'package:full_course/pages/products.dart';
import 'package:full_course/pages/product.dart';
import 'package:full_course/scoped-models/main.dart';
import 'package:full_course/models/product.dart';

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
          '/admin': (BuildContext context) => ProductsAdminPage(model),
        },
        onGenerateRoute: (RouteSettings setting) {
          final List<String> pathElements = setting.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = model.allProducts.firstWhere((Product product) => product.id ==productId);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductPage(product),
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






