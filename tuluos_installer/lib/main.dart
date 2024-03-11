import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/ui/screens/welcome.dart';

final theme = ThemeData().copyWith(
    inputDecorationTheme: const InputDecorationTheme().copyWith(
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.grey),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.black),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.red),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(width: 3, color: Colors.redAccent),
  ),
));

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const WelcomeScreen(),
    );
  }
}

// decoration: const InputDecoration(
//                             enabledBorder: OutlineInputBorder(
//                               borderSide:
//                                   BorderSide(width: 3, color: Colors.grey),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide:
//                                   BorderSide(width: 3, color: Colors.black),
//                             ),
//                             label: Text("Region")),
