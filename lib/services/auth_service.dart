import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/views/auth_gate.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  static const String auth0Domain = 'dev-sdqqsvfi11hhx02d.us.auth0.com';
  static const String auth0ClientId = 'CammOhigYyH161HW6LQ3vL9oZsNOl7Oy';

  final Auth0 auth0 = Auth0(auth0Domain, auth0ClientId);

  Credentials? _credentials;

  Future<bool> login() async {
    try {
      _credentials = await auth0
          .webAuthentication(scheme: 'pocketeer')
          .login(
            audience: 'https://pocketeer-api.linerds.us',
            scopes: {'openid', 'profile', 'email', 'offline_access'},
            redirectUrl:
                'pocketeer://dev-sdqqsvfi11hhx02d.us.auth0.com/android/com.example.pocketeer_mobile/callback',
          );
      if (kDebugMode) {
        print('✅ Успішний вхід! Access token: ${_credentials!.accessToken}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Помилка входу (або скасування): $e');
      }
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      unawaited(auth0.webAuthentication(scheme: 'pocketeer').logout());

      await Future.delayed(const Duration(seconds: 1));

      _credentials = null;

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Помилка виходу: $e');
    }
  }

  void clearCredentials() {
    _credentials = null;
  }

  Credentials? get credentials => _credentials;
  bool get isAuthenticated => _credentials != null;
}
