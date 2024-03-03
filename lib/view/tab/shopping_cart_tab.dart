import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/api_controller.dart';
import '../../model/app_state.dart';
import '../../model/product.dart';
import '../dialog/clear_basket_dialog.dart';
import '../dialog/quantity_dialog.dart';
import '../styles.dart';

class ShoppingCartTab extends StatefulWidget {
  const ShoppingCartTab({super.key});

  @override
  State<ShoppingCartTab> createState() {
    return _ShoppingCartTabState();
  }
}

class _ShoppingCartTabState extends State<ShoppingCartTab> {
  String? name;
  String? email;
  String? location;
  String? pin;
  DateTime dateTime = DateTime.now();
  final _currencyFormat = NumberFormat.currency(symbol: '€ ');

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      AppStateModel model) {
    return SliverChildBuilderDelegate(
      (context, index) {
        final productIndex = index;
        if (model.productsInCart.length > productIndex) {
          return ShoppingCartItem(
            index: index,
            product: model.getProductById(
                model.productsInCart.keys.toList()[productIndex]),
            quantity: model.productsInCart.values.toList()[productIndex],
            lastItem: productIndex == model.productsInCart.length - 1,
            formatter: _currencyFormat,
          );
        } else if (model.productsInCart.keys.length == productIndex &&
            model.productsInCart.isNotEmpty) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return const ClearBasketDialog();
                        },
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                    child: const Icon(CupertinoIcons.delete),
                  ),
                  // SizedBox(width: 75),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "Bruto: ${_currencyFormat.format(model.brutoTotalCost)}",
                            style: Styles.productRowItemPrice,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'BTW: ${_currencyFormat.format(model.subTotalTax)}',
                            style: Styles.productRowItemPrice,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Totaal: ${_currencyFormat.format(model.nettoTotalCost)}",
                            style: Styles.productRowTotal,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ));
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        if (model.totalCartQuantity == 0) {
          return Scaffold(
              body: Column(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.25),
                      child: Image.asset("assets/images/undraw_empty_cart.png",
                          width: MediaQuery.of(context).size.height * 0.30))),
              const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.only(top: 45.0),
                      child: Text("Lege winkelmand"))),
            ],
          ));
        } else {
          return CustomScrollView(
            slivers: <Widget>[
              const CupertinoSliverNavigationBar(
                  largeTitle: Text('Mijn Winkelmand', style: Styles.titleBar)),
              SliverSafeArea(
                top: true,
                minimum: const EdgeInsets.only(top: 30),
                sliver: SliverList(
                  delegate: _buildSliverChildBuilderDelegate(model),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class ShoppingCartItem extends StatelessWidget {
  const ShoppingCartItem({
    required this.index,
    required this.product,
    required this.lastItem,
    required this.quantity,
    required this.formatter,
    super.key,
  });

  final Product product;
  final int index;
  final bool lastItem;
  final int quantity;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                  ApiController.retrieveProductImageUrl(product.id),
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.name,
                            overflow: TextOverflow.clip,
                            style: Styles.productRowItemName,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: () {
                              final model = Provider.of<AppStateModel>(context,
                                  listen: false);
                              model.removeProductFromCart(product.id);
                            },
                            icon: const Icon(
                              CupertinoIcons.delete,
                              semanticLabel: 'Add',
                              color: Color.fromARGB(204, 255, 0, 0),
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children:
                          _buildChild(quantity, formatter, product, context),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_buildChild(int quantity, formatter, Product product, context) {
  if (quantity >= 1) {
    return [
      CupertinoButton.filled(
        minSize: 0,
        padding: const EdgeInsets.all(5),
        child: Text(quantity >= 1 ? '$quantity x ' : '',
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 13,
              fontWeight: FontWeight.w300,
            )),
        onPressed: () {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return QuantityDialog(product: product, quantity: quantity);
            },
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Text(
          '${formatter.format(product.priceNetto)}',
          style: Styles.productRowItemPrice,
        ),
      ),
    ];
  } else {
    return [
      Text(
        '${formatter.format(product.priceNetto)}',
        style: Styles.productRowItemPrice,
      ),
    ];
  }
}
