// lib/core/services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    if (navigatorKey.currentState == null) {
      throw Exception('NavigationService: Cannot navigate, navigatorKey.currentState is null. Ensure the navigatorKey is attached to MaterialApp.');
    }
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> replaceWith(String routeName, {dynamic arguments}) {
    if (navigatorKey.currentState == null) {
      throw Exception('NavigationService: Cannot replace route, navigatorKey.currentState is null. Ensure the navigatorKey is attached to MaterialApp.');
    }
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  void goBack() {
    if (navigatorKey.currentState == null) {
      throw Exception('NavigationService: Cannot go back, navigatorKey.currentState is null. Ensure the navigatorKey is attached to MaterialApp.');
    }
    navigatorKey.currentState!.pop();
  }
}