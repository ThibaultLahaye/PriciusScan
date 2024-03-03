import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'view/app_pousset.dart';
import 'model/app_state.dart';

void main() {
  return runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (_) => AppStateModel()
        ..checkConnection()
        ..autoLoaderCategories()
        ..autoLoadProducts(),
      child: const AppPousset(),
    ),
  );
}
