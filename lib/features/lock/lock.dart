import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_lock/features/app_lock/app_lock.dart';
import 'package:passcode_screen/passcode_screen.dart';

class Lock extends StatefulWidget {
  const Lock({super.key});

  @override
  State<Lock> createState() => _LockState();
}

class _LockState extends State<Lock> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  void _onPasscodeEntered(String enteredPasscode) {
    bool isValid = '123456' == enteredPasscode;
    _verificationNotifier.add(isValid);
  }

  void _unLock() {
    AppLock.of(context)?.didUnlock(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: PasscodeScreen(
        title: const Text(
          "Passcode",
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
        passwordEnteredCallback: _onPasscodeEntered,
        cancelButton: const Text('Cancel'),
        deleteButton: const Text('Delete'),
        shouldTriggerVerification: _verificationNotifier.stream,
        isValidCallback: () {
          _unLock();
        },
      ),
    );
  }
}
