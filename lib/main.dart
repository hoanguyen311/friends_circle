// Flutter code sample for material.Scaffold.1

// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold] and the [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.

import 'package:flutter/material.dart';
import 'package:friends_circle/ui/screens/screens.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  static const String _title = 'Friend Circle';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        UsersScreen.routeName: (context) => UsersScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen()
      },
    );
  }
}