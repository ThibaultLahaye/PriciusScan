import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/api_controller.dart';
import '../../model/app_state.dart';
import '../../model/product.dart';

// ignore: must_be_immutable
class ProductDialog extends StatefulWidget {
  Product product;

  ProductDialog({Key? key, required this.product}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(widget.product.name,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 15.0, color: Colors.black)),
                ) //
                    ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CachedNetworkImage(
                      placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.only(
                                left: 100, right: 100, top: 40, bottom: 40),
                            child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 0, 51, 255),
                                strokeWidth: 5),
                          ),
                      imageUrl: ApiController.retrieveProductImageUrl(
                          widget.product.id),
                      fit: BoxFit.scaleDown,
                      width: 150,
                      height: 150),
                ),
                const SizedBox(height: 20.0),
                Text(
                  '€ ${widget.product.priceNetto.toString()}',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18.0),
                Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final model =
                            Provider.of<AppStateModel>(context, listen: false);
                        model.addProductToCart(widget.product.id);
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                      child: const Text('Toevoegen aan winkelmand',
                          style: TextStyle(fontSize: 10)),
                    )),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
