import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/home.dart';

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
