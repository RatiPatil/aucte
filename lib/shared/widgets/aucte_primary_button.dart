/// AUCTE — Primary filled button.
///
/// Medical green filled button used for primary actions.
/// Full-width by default, customizable via [isFullWidth].
library;

import 'package:flutter/material.dart';

class AuctePrimaryButton extends StatelessWidget {
  const AuctePrimaryButton({
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
        ? FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? const _ButtonSpinner()
                : Icon(icon, size: 20),
            label: Text(label),
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const _ButtonSpinner()
                : Text(label),
          );

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }
}
