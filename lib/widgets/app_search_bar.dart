import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;

  const AppSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onClear,
    this.showClear = true,
  }) : super(key: key);

  void _handleClear() {
    controller.clear();
    onClear?.call();
    onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withOpacity(0.6)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: showClear
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _handleClear,
                      splashRadius: 16,
                    );
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}