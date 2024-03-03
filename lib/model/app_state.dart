import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../controller/api_controller.dart';
import 'category.dart';
import 'product.dart';

enum NetworkStatus { online, offline }

class AppStateModel extends foundation.ChangeNotifier {
  // All the available products.
  List<Product> _availableProducts = [];

  // All the available categories.
  static List<Category> _availableCategories = [];

  // The currently selected category of products.
  // The 'All' category is meant to select all available products
  Category _selectedCategory = const Category(id: 0, name: 'All');

  // The IDs and quantities of products currently in the cart.
  final _productsInCart = <int, int>{};

  void setProductQuantityInCart(int productId, int quantity) {
    try {
      _productsInCart[productId] = quantity;
      notifyListeners();
    } catch (error) {
      throw Exception();
    }
  }

  int? getProductQuantityInCart(int productId) {
    try {
      return _productsInCart[productId];
    } catch (error) {
      return null;
    }
  }

  Product? findProduct(String barcode) {
    for (Product product in _availableProducts) {
      if (product.barcodes.contains(barcode)) {
        return product;
      }
    }
    return null;
  }

  Map<int, int> get productsInCart {
    return Map.from(_productsInCart);
  }

  // Total number of items in the cart.
  int get totalCartQuantity {
    return _productsInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }

  Category get selectedCategory {
    return _selectedCategory;
  }

  // ...
  double get brutoTotalCost {
    return _productsInCart.keys.map((id) {
      // Extended price for product line
      return getProductById(id).priceBruto * _productsInCart[id]!;
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  double get subTotalTax {
    return _productsInCart.keys.map((id) {
      // Extended price for product line
      return getProductById(id).priceBruto *
          _productsInCart[id]! *
          getProductById(id).tax /
          100;
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  // ...
  double get nettoTotalCost {
    return _productsInCart.keys.map((id) {
      // Extended price for product line
      return getProductById(id).priceBruto * _productsInCart[id]! +
          getProductById(id).priceBruto *
              _productsInCart[id]! *
              getProductById(id).tax *
              0.01;
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  // Returns a copy of the list of available products, filtered by category.
  List<Product> getProducts() {
    if (_selectedCategory.name == 'All') {
      return List.from(_availableProducts);
    } else {
      return _availableProducts.where((p) {
        // ignore: unrelated_type_equality_checks
        return p.category == _selectedCategory;
      }).toList();
    }
  }

  // Search the product catalog
  List<Product> search(String searchTerms) {
    return getProducts().where((product) {
      return product.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
  }

  // Adds a product to the cart.
  void addProductToCart(int productId) {
    if (!_productsInCart.containsKey(productId)) {
      _productsInCart[productId] = 1;
    } else {
      _productsInCart[productId] = _productsInCart[productId]! + 1;
    }

    notifyListeners();
  }

  // Removes an item from the cart.
  void removeItemFromCart(int productId) {
    if (_productsInCart.containsKey(productId)) {
      if (_productsInCart[productId] == 1) {
        _productsInCart.remove(productId);
      } else {
        _productsInCart[productId] = _productsInCart[productId]! - 1;
      }
    }

    notifyListeners();
  }

  // Removes all items of a given product from the cart.
  void removeProductFromCart(int productId) {
    _productsInCart.remove(productId);
    notifyListeners();
  }

  // Removes everything from the cart.
  void clearCart() {
    _productsInCart.clear();
    notifyListeners();
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(int id) {
    return _availableProducts.firstWhere((p) => p.id == id);
  }

  // Returns the Category instance matching the provided id.
  static Future<Category> getCategoryById(int id) async {
    try {
      return _availableCategories.firstWhere((c) {
        return c.id == id;
      });
    } catch (e) {
      return const Category(id: 999, name: 'Default');
    }
  }

  // ...

  NetworkStatus _networkStatus = NetworkStatus.offline;

  Future<void> checkConnection() async {
    _networkStatus =
        _getNetworkStatus(await Connectivity().checkConnectivity());

    Connectivity().onConnectivityChanged.listen((status) {
      _networkStatus = _getNetworkStatus(status);

      notifyListeners();
    });

    notifyListeners();
  }

  NetworkStatus _getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.mobile ||
            status == ConnectivityResult.wifi
        ? NetworkStatus.online
        : NetworkStatus.offline;
  }

  NetworkStatus get networkStatus {
    return _networkStatus;
  }

  // ...
  bool _isLoadingProducts = true;
  bool _isLoadingCategories = true;

  void autoLoadProducts() {
    // Initial load on startup
    loadProducts();

    Connectivity().onConnectivityChanged.listen((status) {
      if (_availableProducts.isEmpty) {
        loadProducts();
      }
    });

    // Autoloading every 1 hour
    Stream<dynamic> autoLoaderProducts =
        Stream.periodic(const Duration(seconds: 3600));
    autoLoaderProducts.listen((event) {
      _networkStatus == NetworkStatus.online ? loadProducts() : null;
    });
  }

  void autoLoaderCategories() {
    // Initial load on startup
    loadCategories();

    Connectivity().onConnectivityChanged.listen((status) {
      if (_availableCategories.isEmpty) {
        loadCategories();
      }
    });

    // Autoloading every 1 hour
    Stream<dynamic> autoLoaderCategories =
        Stream.periodic(const Duration(seconds: 3600));
    autoLoaderCategories.listen((event) {
      _networkStatus == NetworkStatus.online ? loadCategories() : null;
    });
  }

  // Loads the list of available products.
  void loadProducts() async {
    // ApiController api_controller = ApiController();

    _isLoadingProducts = true;

    _availableProducts = await ApiController.retrieveAllProducts();
    _isLoadingProducts = false;

    notifyListeners();
  }

  // Loads the list of available categories.
  void loadCategories() async {
    _isLoadingCategories = true;

    _availableCategories = await ApiController.retrieveAllCategories();
    _isLoadingCategories = false;

    notifyListeners();
  }

  bool get isLoading {
    return _isLoadingProducts || _isLoadingCategories;
  }

  void setCategory(Category newCategory) {
    _selectedCategory = newCategory;
    notifyListeners();
  }
}
