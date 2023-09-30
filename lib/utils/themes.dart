import 'package:flutter/material.dart';

var ilColore = const Color(0x00ff6c2f);

var lightCustomColorScheme = ColorScheme.fromSeed(
  seedColor: ilColore,
);

var lightCustomTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightCustomColorScheme,
);

var darkCustomColorScheme = ColorScheme.fromSeed(
  seedColor: ilColore,
  brightness: Brightness.dark,
);

var darkCustomTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkCustomColorScheme,
);
