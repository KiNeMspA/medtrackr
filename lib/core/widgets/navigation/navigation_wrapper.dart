// lib/core/widgets/navigation/navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';

class NavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const NavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: child,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/calendar');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/history');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}