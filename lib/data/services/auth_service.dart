import 'dart:async';
import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocketeer_mobile/core/constants/app_constants.dart';
import 'package:pocketeer_mobile/routes/app_router.dart';

enum AuthResult { success, emailNotVerified, error }

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  final Auth0 auth0 = Auth0(
    AppConstants.auth0Domain,
    AppConstants.auth0ClientId,
  );

  Credentials? _credentials;

  Future<AuthResult> login() async {
    try {
      _credentials = await auth0
          .webAuthentication(scheme: 'pocketeer')
          .login(
            audience: AppConstants.apiBaseUrl,
            scopes: {'openid', 'profile', 'email', 'offline_access'},
            redirectUrl:
                'pocketeer://dev-sdqqsvfi11hhx02d.us.auth0.com/android/com.example.pocketeer_mobile/callback',
          );

      if (kDebugMode) {
        print('✅ Login successful. Access token: ${_credentials!.accessToken}');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/users/me'),
        headers: {'Authorization': 'Bearer ${_credentials!.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isVerified = data['email_verified'] ?? false;

        if (!isVerified) {
          if (kDebugMode) print('⚠️ Email not verified');
          return AuthResult.emailNotVerified;
        }

        if (kDebugMode) print('✅ Email verified');
        return AuthResult.success;
      }

      if (response.statusCode == 403 &&
          response.body.contains('email not verified')) {
        return AuthResult.emailNotVerified;
      }

      return AuthResult.error;
    } catch (e) {
      if (e.toString().contains('access_denied') ||
          e.toString().contains('email not verified')) {
        return AuthResult.emailNotVerified;
      }

      if (kDebugMode) print('❌ Login error: $e');
      return AuthResult.error;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      unawaited(auth0.webAuthentication(scheme: 'pocketeer').logout());
      await Future.delayed(const Duration(seconds: 1));
      _credentials = null;

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.authGate);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Logout error: $e');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (_credentials == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/api/users/me'),
        headers: {
          'Authorization': 'Bearer ${_credentials!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        if (kDebugMode) print('✅ Account deleted');
      } else {
        if (kDebugMode) {
          print('⚠️ Delete error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }

      _credentials = null;
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.authGate);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Exception during deleteAccount: $e');
      _credentials = null;
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.authGate);
      }
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (_credentials == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/auth/change-password'),
        headers: {
          'Authorization': 'Bearer ${_credentials!.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print('✅ Password changed');
        return true;
      }

      if (kDebugMode) {
        print('⚠️ Password change failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Password change error: $e');
      return false;
    }
  }

  bool get canChangePassword {
    if (_credentials == null) return false;
    final sub = _credentials!.user.sub;
    return sub.startsWith('auth0|');
  }

  void clearCredentials() => _credentials = null;

  Credentials? get credentials => _credentials;
  bool get isAuthenticated => _credentials != null;

  String ensureToken() {
    final token = _credentials?.accessToken;
    if (token == null) {
      throw Exception('Not authorized');
    }
    return token;
  }
}
