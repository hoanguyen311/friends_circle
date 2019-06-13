import 'package:flutter/material.dart';

class MenuPopupChoice {
  final String title;
  final IconData iconData;
  final MenuPopupChoices choiceKey;

  MenuPopupChoice({ this.title, this.iconData, this.choiceKey });
}

enum MenuPopupChoices {
  logout,
  settings
}