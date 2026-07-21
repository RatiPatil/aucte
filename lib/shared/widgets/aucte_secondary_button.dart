/// AUCTE — Secondary outlined button.
///
/// Green-outlined button used for secondary actions.
library;

import 'package:flutter/material.dart';

class AucteSecondaryButton extends StatelessWidget {
  const AucteSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? _ButtonSpinner(color: Theme.of(context).colorScheme.primary)
                : Icon(icon, size: 20),
            label: Text(label),
          )
        : OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? _ButtonSpinner(color: Theme.of(context).colorScheme.primary)
                : Text(label),
          );

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
