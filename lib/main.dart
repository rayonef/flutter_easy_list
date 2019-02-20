import 'package:flutter/material.dart';

// import 'package:full_course/pages/auth.dart';
import 'package:full_course/pages/products_admin.dart';
import 'package:full_course/pages/products.dart';
import 'package:full_course/pages/product.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget { 
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  List<Map<String, String>> _products = [];

  void _addProduct(Map<String, String> product) {
    setState(() {
      _products.add(product);
    });
    print(_products);
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepPurple,
      ),
      // home: AuthPage(),
      routes:{ 
        '/': (BuildContext context) => ProductsPage(_products, _addProduct, _deleteProduct),
        '/admin': (BuildContext context) => ProductsAdminPage()
      },
      onGenerateRoute: (RouteSettings setting) {
        final List<String> pathElements = setting.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'product') {
          final int index = int.parse(pathElements[2]);
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => ProductPage(
                _products[index]['title'], 
                _products[index]['imageUrl']
              ),
          );
        }
        return null;
      },
      onUnknownRoute: (RouteSettings setting) {
        return MaterialPageRoute(
          builder: (BuildContext context) => ProductsPage(_products, _addProduct, _deleteProduct),
        );
      },
    );
  }
}






