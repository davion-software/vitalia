import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repository.dart';
import 'data/store.dart';
import 'theme/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: VitaliaPalette.paper,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final store = VitaliaStore(repository: PrefsRepository());
  await store.load();
  runApp(VitaliaApp(store: store));
}
