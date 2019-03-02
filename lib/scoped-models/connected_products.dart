import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import 'package:full_course/models/product.dart';
import 'package:full_course/models/user.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selectedProductId;
  bool _isLoading = false;

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
    return _products.indexWhere((Product product) => product.id ==_selectedProductId);
  }

  String get selectedProductId {
    return _selectedProductId;
  }

  Product get selectedProduct {
    return _selectedProductId != null 
      ? _products.firstWhere((Product product) => product.id == _selectedProductId) 
      : null;
  }

  bool get showFavorites {
    return _showFavorites;
  }

  Future<dynamic> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http.get('https://flutter-easylist-11880.firebaseio.com/products.json')
      .then((http.Response response) {
        final List<Product> fetchedProducts = [];
        final Map<String, dynamic> productListData = 
          json.decode(response.body);
        if (productListData == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
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
        _isLoading = false;
        notifyListeners();
        _selectedProductId = null;
      });
  }

  Future<bool> addProduct(String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imageUrl': 'https://static01.nyt.com/images/2018/03/14/dining/14FIlipino1-sub/14FIlipino1-sub-articleLarge.jpg?quality=75&auto=webp&disable=upscale',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return http.post('https://flutter-easylist-11880.firebaseio.com/products.json',
      body: json.encode(productData)
    ).then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }
      print(response);
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
      return true;
    }).catchError((err) {
      print(err);
      return false;
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<dynamic> updateProduct(String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': 'https://static01.nyt.com/images/2018/03/14/dining/14FIlipino1-sub/14FIlipino1-sub-articleLarge.jpg?quality=75&auto=webp&disable=upscale',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http.put('https://flutter-easylist-11880.firebaseio.com/products/${selectedProduct.id}.json',
      body: json.encode(updateData)
    ).then((http.Response response) {
      _isLoading = false;
      final Product product = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        imageUrl: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId
      );
      _products[selectedProductIndex] = product;
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selectedProductId = null;
    notifyListeners();
    http.delete('https://flutter-easylist-11880.firebaseio.com/products/$deletedProductId.json')
      .then((http.Response response) {
        _isLoading = false;
        notifyListeners();
      });
  }

  void toggleFavorite() {
    final bool isFaved =_products[selectedProductIndex].isFavorite;
    final Product updatedProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      imageUrl: selectedProduct.imageUrl,
      price: selectedProduct.price,
      isFavorite: !isFaved,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId
    );
    
    _products[selectedProductIndex] = updatedProduct;
    _selectedProductId = null;
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;
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

mixin UtitlityModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}