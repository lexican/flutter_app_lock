import 'package:flutter/material.dart';
import 'package:flutter_app_lock/features/app_lock/app_lock.dart';
import 'package:flutter_app_lock/features/home/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return AppLock(
      builder: (args) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: <String, WidgetBuilder>{
            '/': (context) => const Home(),
          },
        );
      },
      enabled: false,
    );
  }
}
