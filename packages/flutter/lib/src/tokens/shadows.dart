import 'package:flutter/material.dart';

class AerosShadows {
  AerosShadows._();

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x12000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0xCCE5E5E5), blurRadius: 0, spreadRadius: 1),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 20)),
  ];
}
