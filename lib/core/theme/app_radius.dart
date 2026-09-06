import 'package:flutter/material.dart';

/// MoneyMateX Soft Shape Radii (0.25rem = 4dp Base)
abstract class AppRadius {
  static const double xs = 4.0;
  static const double s = 4.0;
  static const double sm = 4.0;
  static const double m = 6.0;
  static const double md = 6.0;
  static const double l = 8.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double full = 9999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderL = BorderRadius.all(Radius.circular(l));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}
