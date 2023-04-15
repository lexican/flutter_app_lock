import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_lock/features/lock/lock.dart';

class AppLock extends StatefulWidget {
  final Widget Function(Object?) builder;
  final bool enabled;
  final Duration backgroundLockLatency;
  const AppLock({
    super.key,
    required this.builder,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 60),
  });

  static AppLockState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppLockState>();

  @override
  State<AppLock> createState() => AppLockState();
}

class AppLockState extends State<AppLock> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late bool _enabled;
  late bool _didUnlockForAppLaunch;
  late bool _isLocked;

  Timer? _backgroundLockLatencyTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _didUnlockForAppLaunch = true;
    _isLocked = false;
    _enabled = widget.enabled;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _backgroundLockLatencyTimer?.cancel();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) {
      return;
    }
    if (state == AppLifecycleState.paused && !_isLocked) {
      _backgroundLockLatencyTimer =
          Timer(widget.backgroundLockLatency, () => _showLockScreen());
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundLockLatencyTimer?.cancel();
    }
  }

  Future<Object?> _showLockScreen() {
    return _navigatorKey.currentState!.pushNamed<Object?>('/lock-screen');
  }

  void didUnlock(Object? args) {
    if (_didUnlockForAppLaunch) {
      _didUnlockOnAppLaunch(true);
    } else {
      _didUnlockOnAppPaused(true);
    }
  }

  void _didUnlockOnAppLaunch(Object? args) {
    _didUnlockForAppLaunch = false;
    _navigatorKey.currentState!
        .pushReplacementNamed('/unlocked', arguments: args);
  }

  void _didUnlockOnAppPaused(Object? args) {
    _isLocked = false;
    _navigatorKey.currentState!.pop(args);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: widget.enabled ? _lockScreen : widget.builder(null),
      navigatorKey: _navigatorKey,
      routes: <String, WidgetBuilder>{
        '/lock-screen': (context) => _lockScreen,
        '/unlocked': (context) =>
            widget.builder(ModalRoute.of(context)!.settings.arguments)
      },
    );
  }

  Widget get _lockScreen {
    return WillPopScope(
      child: const Lock(),
      onWillPop: () => Future.value(false),
    );
  }
}
