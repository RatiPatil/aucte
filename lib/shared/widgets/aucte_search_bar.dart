/// AUCTE — Search bar widget.
///
/// Outlined text field with a search icon, used on the dashboard
/// and future terminology search screens.
library;

import 'package:flutter/material.dart';

class AucteSearchBar extends StatelessWidget {
  const AucteSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search NAMASTE terminology...',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.onTap,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 24),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller != null && controller!.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  controller!.clear();
                  onChanged?.call('');
                },
              ),
            IconButton(
              icon: const Icon(Icons.tune, size: 24),
              onPressed: () {}, // Filter action
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
