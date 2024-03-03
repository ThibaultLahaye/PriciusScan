import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/secrets.dart';
import '../model/category.dart';
import '../model/product.dart';

class ApiController {
  static Future<Product> retrieveProduct(String barcode) async {
    final httpsUri = Uri.parse(
        "https://$apiKey:$apiSecret@api.onlinefact.be/products.php?barcode=$barcode");

    final requestResponse = await http.get(httpsUri);
    if (requestResponse.statusCode == 200) {
      final data = (jsonDecode(requestResponse.body))['results'][0];
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to retrieve product!');
    }
  }

  static Future<List<Product>> retrieveAllProducts() async {
    final httpsUri =
        Uri.parse("https://$apiKey:$apiSecret@api.onlinefact.be/products.php");

    final requestResponse = await http.get(httpsUri);
    if (requestResponse.statusCode == 200) {
      List<Product> products = [];

      final responseBody = (jsonDecode(requestResponse.body))['results'];
      responseBody.forEach((element) {
        Product product = Product.fromJson(element);
        if (product.barcodes.isNotEmpty) {
          products.add(product);
        }
      });
      return products;
    } else {
      throw Exception('Failed to retrieve all products!');
    }
  }

  static String retrieveProductImageUrl(int productId) {
    final httpsUri =
        "https://$apiKey:$apiSecret@api.onlinefact.be/image.php?product_id=$productId";
    return httpsUri;
  }

  static Future<Category> retrieveCategory(int categoryId) async {
    final httpsUri = Uri.parse(
        "https://$apiKey:$apiSecret@api.onlinefact.be/categories.php??category_id=$categoryId");

    final requestResponse = await http.get(httpsUri);
    if (requestResponse.statusCode == 200) {
      final data = (jsonDecode(requestResponse.body))['results'][0];
      return Category.fromJson(data);
    } else {
      throw Exception('Failed to retrieve product category!');
    }
  }

  static Future<List<Category>> retrieveAllCategories() async {
    final httpsUri = Uri.parse(
        "https://$apiKey:$apiSecret@api.onlinefact.be/categories.php");

    final requestResponse = await http.get(httpsUri);
    if (requestResponse.statusCode == 200) {
      List<Category> categories = [];

      final responseBody = (jsonDecode(requestResponse.body))['results'];
      await responseBody
          .forEach((element) => categories.add(Category.fromJson(element)));
      return categories;
    } else {
      throw Exception('Failed to retrieve all product categories!');
    }
  }
}
