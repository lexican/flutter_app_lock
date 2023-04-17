import 'package:flutter/material.dart';
import 'package:flutter_app_lock/features/app_lock/app_lock.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppLock.of(context)?.enable();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Lottie.asset(
          'assets/animations/wallet-coin.json',
          repeat: true,
        ),
      ),
    );
  }
}
