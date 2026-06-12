import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double padding(BuildContext context) => isMobile(context) ? 16.0 : 24.0;
  static double cardPadding(BuildContext context) => isMobile(context) ? 12.0 : 20.0;
  static double cardRadius(BuildContext context) => isMobile(context) ? 14.0 : 20.0;

  static double fontScale(BuildContext context) => (width(context) / 375).clamp(0.85, 1.3);

  static double fontSize(BuildContext context, double size) => size * fontScale(context);

  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.all(padding(context));
  static EdgeInsets cardContentPadding(BuildContext context) => EdgeInsets.all(cardPadding(context));

  static double bottomSheetHeight(BuildContext context) => (height(context) * 0.85).clamp(400, 800);

  static double textScale(BuildContext context, {double min = 0.85, double max = 1.2}) {
    return (width(context) / 375).clamp(min, max);
  }
}
