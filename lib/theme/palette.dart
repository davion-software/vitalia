import 'package:flutter/material.dart';

import 'package:vitalia/core/medication.dart';

abstract final class VitaliaPalette {
  static const paper = Color(0xFFF7F3EA);
  static const paperDeep = Color(0xFFEFE8D8);
  static const ink = Color(0xFF1F1A16);
  static const inkSoft = Color(0xFF6B6358);
  static const sage = Color(0xFF2F4A3C);
  static const sageMist = Color(0xFFD5DFD4);
  static const line = Color(0xFFE4DCC8);
  static const terracotta = Color(0xFFC46B3A);
  static const blush = Color(0xFFC9898A);
}

Color colorFor(PillColor color) {
  switch (color) {
    case PillColor.sage:
      return const Color(0xFF5F7D66);
    case PillColor.moss:
      return const Color(0xFF7A8F45);
    case PillColor.terracotta:
      return VitaliaPalette.terracotta;
    case PillColor.clay:
      return const Color(0xFFB07D5A);
    case PillColor.sand:
      return const Color(0xFFD4B48A);
    case PillColor.slate:
      return const Color(0xFF5E6A75);
    case PillColor.ink:
      return const Color(0xFF2A2622);
    case PillColor.blush:
      return VitaliaPalette.blush;
  }
}

String pillColorName(PillColor color) {
  switch (color) {
    case PillColor.sage:
      return 'Sage';
    case PillColor.moss:
      return 'Moss';
    case PillColor.terracotta:
      return 'Terracotta';
    case PillColor.clay:
      return 'Clay';
    case PillColor.sand:
      return 'Sand';
    case PillColor.slate:
      return 'Slate';
    case PillColor.ink:
      return 'Ink';
    case PillColor.blush:
      return 'Blush';
  }
}

String pillShapeName(PillShape shape) {
  switch (shape) {
    case PillShape.capsule:
      return 'Capsule';
    case PillShape.tablet:
      return 'Tablet';
    case PillShape.softgel:
      return 'Softgel';
  }
}
