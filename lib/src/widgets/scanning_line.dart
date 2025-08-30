import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScanningLine extends StatefulWidget {
  const ScanningLine({super.key});

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<AlignmentGeometry> _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _animation = Tween<Alignment>(
            begin: Alignment.topCenter, end: Alignment.bottomCenter)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    super.initState();

    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: AlignmentGeometry.center.add(AlignmentGeometry.xy(0, -.4)),
          child: FractionallySizedBox(
            widthFactor: .82,
            heightFactor: .82,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Container(
                decoration: BoxDecoration(
                  //TODO: delete just for testing
                  //color: const Color.fromARGB(212, 255, 193, 7),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Align(alignment: _animation.value, child: child),
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(900),
          color: Colors.redAccent,
        ),
        height: 4,
      ),
    );
  }
}
