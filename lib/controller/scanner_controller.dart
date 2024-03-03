import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import '../exception/nothing_scanned_exception.dart';

class ScannerController {
  static Future<String> scanBarcode() async {
    String scannedBarcode = "";
    try {
      scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Annuleer', true, ScanMode.BARCODE);
      if (scannedBarcode == "") {
        throw NothingScannedException();
      }
      return scannedBarcode;
    } on PlatformException {
      throw NothingScannedException();
    }
  }
}
