import 'package:flutter/material.dart';

/// AppBar chung cho tất cả màn hình có nút back
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng theme mặc định trừ khi có override
    final appBarTheme = Theme.of(context).appBarTheme;
    
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Quay lại',
      ),
      title: Text(title),
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      elevation: elevation ?? appBarTheme.elevation,
      centerTitle: appBarTheme.centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}