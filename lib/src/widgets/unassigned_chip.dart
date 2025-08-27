import 'package:flutter/material.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/utils/extensions.dart';
import 'package:split_bill/src/widgets/animated_switcher_text.dart';

class UnassignedChip extends StatelessWidget {
  const UnassignedChip({super.key, required this.item});

  final ItemGroup item;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: false,
      onSelected: (bool selected) {},
      backgroundColor: context.colorScheme.surfaceContainerHighest,

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
          Text(" (${item.unitPrice}€)"),
        ],
      ),
    );
  }
}
