import 'package:flutter/material.dart';

/// Responsive helper for Desktop (>= 900px) and Mobile (< 900px)
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  static const double desktopBreakpoint = 900.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
