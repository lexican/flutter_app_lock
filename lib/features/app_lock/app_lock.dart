import 'dart:async';

import 'package:flutter/material.dart';

class AppLock extends StatefulWidget {
  final Widget Function(Object?) builder;
  final bool enabled;
  final int lockDurationSeconds;
  const AppLock({
    super.key,
    required this.builder,
    this.enabled = true,
    this.lockDurationSeconds = 60,
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
  late int _lockDurationSeconds;

  DateTime? _dateTimeBeforeAppWasInactive;
  bool _isInactive = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _didUnlockForAppLaunch = true;
    _isLocked = false;
    _enabled = widget.enabled;
    _lockDurationSeconds = widget.lockDurationSeconds;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _showLock();
    } else if (state == AppLifecycleState.inactive) {
      if (!_isInactive) {
        _isInactive = true;
        _dateTimeBeforeAppWasInactive = DateTime.now();
      }
    }
  }

  void _showLock() async {
    if (_dateTimeBeforeAppWasInactive != null) {
      var difference =
          DateTime.now().difference(_dateTimeBeforeAppWasInactive!);
      if (difference.inSeconds >= _lockDurationSeconds) {
        if (!_isLocked) {
          _isLocked = true;
          _showLockScreen();
        }
      }
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
    _isInactive = false;
    _dateTimeBeforeAppWasInactive = null;
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
      child: const SizedBox(),
      onWillPop: () => Future.value(false),
    );
  }
}
