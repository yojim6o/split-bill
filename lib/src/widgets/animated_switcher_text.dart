import 'package:flutter/cupertino.dart';

class AnimatedSwitcherText extends StatelessWidget {
  const AnimatedSwitcherText({
    super.key,
    required this.uKey,
    required this.value,
  });
  final int uKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Text(key: ValueKey(uKey), value),
    );
  }
}
