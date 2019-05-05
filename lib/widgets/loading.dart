import 'package:flutter/cupertino.dart';

class Loading extends StatelessWidget {
  final double radius;

  const Loading({Key key, this.radius}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CupertinoActivityIndicator(animating: true, radius: radius));
  }
}
