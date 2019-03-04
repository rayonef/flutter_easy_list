import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import 'package:full_course/models/product.dart';
import 'package:full_course/models/user.dart';
import 'package:full_course/models/auth.dart';

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
    return http.get('https://flutter-easylist-11880.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
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
    return http.post('https://flutter-easylist-11880.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
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
    return http.put('https://flutter-easylist-11880.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
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
    http.delete('https://flutter-easylist-11880.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
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
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password, [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    final String url = mode == AuthMode.Login 
      ? 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyA9ZXL__z5G2gnEgV4kVK-JfC0lSwf1Hwg'
      : 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyA9ZXL__z5G2gnEgV4kVK-JfC0lSwf1Hwg';
    
    final http.Response response = await http.post(
      url,
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'}
    );
    
    final Map<String, dynamic> resData =json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong';
    if (resData.containsKey('idToken')) {
      hasError = false;
      message = 'Auth success!';
      _userSubject.add(true);
      _authenticatedUser = User(id: resData['localId'], email: email, token: resData['idToken']);
      setAuthTimeout(int.parse(resData['expiresIn']));
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds: int.parse(resData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', resData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', resData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (resData['error']['message'] == 'EMAIL_NOT_FOUND' || resData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid credentials';
    } else if (resData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    }
    _isLoading = false;
    notifyListeners();
    return { 'success':  !hasError, 'message': message };
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTime = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now  =DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTime);
      if (parsedExpiryTime.isBefore(now)) {
        logout();
        return;
      }
      final String email = prefs.getString('userEmail');
      final String id = prefs.getString('userId'); 
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: id, email: email, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners(); 
    }
  }

  void logout() async {
    print('logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    _userSubject.add(false);
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtitlityModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}