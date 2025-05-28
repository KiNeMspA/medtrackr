// In lib/core/widgets/buttons/animated_action_button.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class AnimatedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AnimatedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: AppConstants.actionButtonStyle.copyWith(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0)),
        ),
      ),
    );
  }
}