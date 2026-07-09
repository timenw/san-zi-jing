import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme.dart';
import 'screens/catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.loadLast();
  runApp(
    Provider<AppState>.value(
      value: state,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲子共读三字经',
      theme: GuoFeng.theme(),
      home: const CatalogPage(),
    );
  }
}
