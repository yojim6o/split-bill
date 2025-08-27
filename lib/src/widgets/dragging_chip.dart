import 'package:flutter/material.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/utils/extensions.dart';

class DraggingChip extends StatefulWidget {
  const DraggingChip({super.key, required this.item});

  final ItemGroup item;

  @override
  State<DraggingChip> createState() => _DraggingChipState();
}

class _DraggingChipState extends State<DraggingChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animatedX;
  late final Animation<double> _animatedY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animatedX = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));
    _animatedY = Tween<double>(
      begin: 0.5,
      end: -0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(_animatedX.value, _animatedY.value),
          child: FilterChip(
            selected: false,
            onSelected: (value) {},
            backgroundColor: context.colorScheme.tertiaryContainer,
            shape: const StadiumBorder(
              side: BorderSide(width: 0, color: Colors.transparent),
            ),
            label: Text("${widget.item.name} ×1 (\$${widget.item.unitPrice})"),
          ),
        ),
      ),
    );
  }
}
