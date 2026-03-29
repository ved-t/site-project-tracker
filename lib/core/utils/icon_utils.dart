import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IconUtils {
  static const List<IconData> _knownIcons = [
    // Default Material Icons (from seeded categories)
    Icons.engineering,
    Icons.construction,
    Icons.local_shipping,
    Icons.receipt_long,
    Icons.handyman,
    Icons.fastfood,
    Icons.miscellaneous_services,

    // Lucide Icons (from category picker)
    LucideIcons.hammer,
    LucideIcons.store,
    LucideIcons.wrench,
    LucideIcons.layoutGrid,
    LucideIcons.moreHorizontal,
  ];

  /// Reconstructs an [IconData] from a saved codePoint safely.
  /// This prevents Flutter AOT tree-shaking errors and correctly resolves
  /// cross-family icons (e.g. Material vs Lucide) without hardcoding font families.
  static IconData getIconFromCodePoint(int codePoint) {
    for (final icon in _knownIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    // Fallback to avoid dynamic IconData initialization
    return Icons.category;
  }
}
