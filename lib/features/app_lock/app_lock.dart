import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that uses app lifecycle events for displaying or hiding a lock screen.
/// This Widget should be wrapped around `MyApp` widget (or something similar).

/// [builder] is a function that takes in an [Object] as its argument and should return a [Widget]. Calling `AppLock.of(context).didUnlock();` provides the argument [Object].

/// [enabled] determines if the [lockScreen] should be displayed or hidden on app launch and subsequent app pauses.
/// The enabled value can be changed by calling any of the following methods.  `AppLock.of(context).enable();` enables the app lock, `AppLock.of(context).disable();` disables the app lock or `AppLock.of(context).setEnabled(bool);` sets the app lock based on the passed boolean value.

/// [backgroundLockLatency] determines how long the app is allowed to spend in the background before the lock screen is displayed. This defaults to 60 seconds (one minute).

/// [lockScreen] is a [widget] that handles authentication and should call `AppLock.of(context).didUnlock();` after a successful authentication.
class AppLock extends StatefulWidget {
  final Widget Function(Object?) builder;
  final bool enabled;
  final Duration backgroundLockLatency;
  final Widget lockScreen;
  const AppLock({
    super.key,
    required this.builder,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 60),
    required this.lockScreen,
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
    _didUnlockForAppLaunch = !widget.enabled;
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

  /// If [enabled] is true, [AppLock] displays the [lockScreen] on subsequent app pauses; otherwise, [AppLock] does not display it on subsequent app pauses.
  void setEnabled(bool enabled) {
    if (enabled) {
      enable();
    } else {
      disable();
    }
  }

  ///Ensures that the [AppLock] displays the [lockScreen] on consecutive app pauses.
  void enable() {
    setState(() {
      _enabled = true;
    });
  }

  ///Ensures that the [AppLock] doesn't display the [lockScreen] on consecutive app pauses.
  void disable() {
    setState(() {
      _enabled = false;
    });
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
      child: widget.lockScreen,
      onWillPop: () => Future.value(false),
    );
  }
  
}
