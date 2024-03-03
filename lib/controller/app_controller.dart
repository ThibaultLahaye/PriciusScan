import 'package:provider/provider.dart';
import '../exception/nothing_scanned_exception.dart';
import '../exception/product_not_found_exception.dart';
import '../model/app_state.dart';
import '../model/product.dart';
import 'scanner_controller.dart';

class AppController {
  static Future<Product> scanAndRetrieveProduct(context) async {
    try {
      String barcode = await ScannerController.scanBarcode();

      final model = Provider.of<AppStateModel>(context, listen: false);
      Product? retrievedProduct = model.findProduct(barcode);
      if (retrievedProduct != null) {
        return retrievedProduct;
      } else {
        throw ProductNotFoundException();
      }
    } on NothingScannedException {
      throw NothingScannedException();
    }
  }
}
