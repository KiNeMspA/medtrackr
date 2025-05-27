import 'package:flutter/material.dart';

class DialogThemes {
  static const warning = DialogThemeData(
    backgroundColor: Colors.orangeAccent,
    titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    contentTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
  );

  static const information = DialogThemeData(
    backgroundColor: Colors.blueAccent,
    titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
  );
}