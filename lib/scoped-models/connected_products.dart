import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import 'package:full_course/models/product.dart';
import 'package:full_course/models/user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  User _authenticatedUser;
  int _selectedProductIndex;

  void addProduct(String title, String description, String image, double price) {
    print(_authenticatedUser.email);

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imageUrl': 'https://static01.nyt.com/images/2018/03/14/dining/14FIlipino1-sub/14FIlipino1-sub-articleLarge.jpg?quality=75&auto=webp&disable=upscale',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    http.post('https://flutter-easylist-11880.firebaseio.com/products.json',
      body: json.encode(productData)
    ).then((http.Response response) {
      final Map<String, dynamic> res = json.decode(response.body);
      final Product newProduct = Product(
        id: res['id'],
        title: title,
        description: description,
        imageUrl: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id
      );
      _products.add(newProduct);
      notifyListeners();
    }).catchError((err) {
      print(err);
    });
  }
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    return _selectedProductIndex != null ? _products[_selectedProductIndex] : null;
  }

  bool get showFavorites {
    return _showFavorites;
  }

  void fetchProducts() {
    http.get('https://flutter-easylist-11880.firebaseio.com/products.json')
      .then((http.Response response) {
        final List<Product> fetchedProducts = [];
        final Map<String, dynamic> productListData = 
          json.decode(response.body);
        productListData.forEach((String productId, dynamic productData) {
          final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
          );
          fetchedProducts.add(product);
        });
        _products = fetchedProducts;
        notifyListeners();
      });
  }

  void updateProduct(String title, String description, String image, double price) {
    final Product product = Product(
      title: title,
      description: description,
      imageUrl: image,
      price: price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId
    );
    _products[_selectedProductIndex] = product;
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selectedProductIndex);
    notifyListeners();
  }

  void toggleFavorite() {
    final bool isFaved =_products[_selectedProductIndex].isFavorite;
    final Product updatedProduct = Product(
      title: selectedProduct.title,
      description: selectedProduct.description,
      imageUrl: selectedProduct.imageUrl,
      price: selectedProduct.price,
      isFavorite: !isFaved,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId
    );
    _products[_selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {

  void login(String email, String password) {
    _authenticatedUser = User(id: 'asdfasdf', email: email, password: password);
    notifyListeners();
  }
}