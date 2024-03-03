import 'app_state.dart';
import 'category.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceNetto,
    required this.priceBruto,
    required this.images,
    required this.tax,
    required this.barcodes,
  });

  final int id;
  final String name;
  final Future<Category> category;
  final double priceNetto;
  final double priceBruto;
  final int images;
  final double tax;
  final List<String> barcodes;

  @override
  String toString() => '$name (id=$id)';

  static void fetch(json) async {
    await AppStateModel.getCategoryById(int.parse(json['categorie_id']));
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> barcodes = List.empty(growable: true);
    if (json["barcode"] is String && json["barcode"] != "") {
      barcodes.add(json["barcode"]);
    } else if (json["barcode"] is List) {
      for (var barcode in json["barcode"]) {
        barcodes.add(barcode);
      }
    }

    return Product(
      id: int.parse(json['product_id']),
      name: json['description'],
      priceNetto: double.parse(json['pricenetto']),
      priceBruto: double.parse(json['pricebruto']),
      category: AppStateModel.getCategoryById(int.parse(json['categorie_id'])),
      images: int.parse(json['images']),
      barcodes: barcodes,
      tax: double.parse(json['tax']),
    );
  }
}
