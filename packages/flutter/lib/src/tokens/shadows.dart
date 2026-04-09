import 'package:flutter/material.dart';

class AerosShadows {
  AerosShadows._();

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0D0A0F2E), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x120A0F2E), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0xCCE2E5F0), blurRadius: 0, spreadRadius: 1),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x140A0F2E), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A0A0F2E), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x330A0F2E), blurRadius: 40, offset: Offset(0, 20)),
  ];
}
