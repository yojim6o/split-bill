import 'package:flutter/material.dart';
import 'package:split_bill/src/models/assigned_item.dart';
import 'package:split_bill/src/utils/extensions.dart';
import 'package:split_bill/src/widgets/animated_switcher_text.dart';

class AssignedChip extends StatelessWidget {
  const AssignedChip({super.key, required this.item});

  final AssignedItem item;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: true,
      onSelected: (bool selected) {},
      selectedColor: context.colorScheme.tertiaryFixed,
      shape: StadiumBorder(
        side: BorderSide(width: 0, color: Colors.transparent),
      ),
      labelStyle: TextStyle(color: context.colorScheme.onSurface),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${item.name} ×"),
          AnimatedSwitcherText(
            uKey: item.quantity,
            value: item.quantity.toString(),
          ),
        ],
      ),
    );
  }
}
