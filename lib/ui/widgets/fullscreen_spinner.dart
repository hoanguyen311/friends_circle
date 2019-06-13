import 'package:flutter/material.dart';
import 'package:friends_circle/ui/widgets/spinner.dart';

class FullScreenSpinner extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  FullScreenSpinner({ this.isLoading, this.child });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          child: isLoading ? Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(
              child: Spinner(),
            ),
          ) : Container(),
        )
      ],
    );
  }
}
