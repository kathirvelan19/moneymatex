import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('AppRouteObserver DID PUSH: ${route.settings.name}');
  }
}
