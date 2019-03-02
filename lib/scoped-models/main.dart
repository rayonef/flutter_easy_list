import 'package:scoped_model/scoped_model.dart';

import 'package:full_course/scoped-models/connected_products.dart';

class MainModel extends Model  with ConnectedProductsModel, UserModel, ProductsModel, UtitlityModel {}