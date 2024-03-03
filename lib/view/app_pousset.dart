import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/app_controller.dart';
import '../exception/product_not_found_exception.dart';
import '../model/app_state.dart';
import '../model/product.dart';
import 'dialog/fetching_products_dialog.dart';
import 'dialog/no_connection_dialog.dart';
import 'dialog/product_dialog.dart';
import 'dialog/product_not_found_dialog.dart';
import 'tab/shopping_cart_tab.dart';
import 'tab/start_tab.dart';

class AppPousset extends StatelessWidget {
  const AppPousset({super.key});

  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatelessWidget {
  const CupertinoStoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context, listen: true);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: const ScannerButton(),
      bottomNavigationBar: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Start',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  const Icon(Icons.shopping_basket),
                  _buildChild(model.totalCartQuantity),
                ],
              ),
              label: 'Winkelmand',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          late final CupertinoTabView returnValue;
          switch (index) {
            case 0:
              returnValue = CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: StartTab(),
                );
              });
              break;
            case 1:
              returnValue = CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: ShoppingCartTab(),
                );
              });
              break;
          }
          return returnValue;
        },
      ),
    );
  }
}

class ScannerButton extends StatelessWidget {
  const ScannerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 100, right: 10),
          child: FloatingActionButton(
            onPressed: () async {
              final model = Provider.of<AppStateModel>(context, listen: false);
              if (model.networkStatus == NetworkStatus.offline) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return const NoConnectionDialog();
                  },
                );
              } else if (!model.isLoading) {
                try {
                  Product? scannedProduct =
                      await AppController.scanAndRetrieveProduct(context);
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      Product product = scannedProduct;
                      return ProductDialog(product: product);
                    },
                  );
                } on ProductNotFoundException {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return const ProductNotFoundDialog();
                    },
                  );
                }
              } else {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return const FetchingProductsDialog();
                  },
                );
              }
            },
            backgroundColor: const Color.fromARGB(255, 0, 51, 255),
            child: const ScannerButtonMode(),
          ),
        ),
      ],
    );
  }
}

class ScannerButtonMode extends StatefulWidget {
  const ScannerButtonMode({super.key});

  @override
  State<ScannerButtonMode> createState() => _ScannerButtonModeState();
}

class _ScannerButtonModeState extends State<ScannerButtonMode> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context, listen: true);

    if (model.networkStatus == NetworkStatus.online) {
      if (model.isLoading) {
        return Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
      } else {
        return const Icon(Icons.photo_camera);
      }
    } else {
      return const Icon(Icons.error_outline);
    }
  }
}

Widget _buildChild(int quantity) {
  if (quantity > 0) {
    return Positioned(
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(
          minWidth: 12,
          minHeight: 12,
        ),
        child: Text(
          quantity.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } else {
    // terurn invisuble widget
    return const SizedBox.shrink();
  }
}
