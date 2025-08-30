import 'package:flutter/material.dart';
import 'package:split_bill/src/models/assigned_item.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/utils/extensions.dart';
import 'package:split_bill/src/widgets/animated_switcher_text.dart';

class MyCustomChip extends StatelessWidget {
  const MyCustomChip._({
    required this.item,
    required this.selected,
    required this.color,
  });

  final dynamic item;
  final bool selected;
  final Color color;

  factory MyCustomChip.unassigned(BuildContext context, ItemGroup item) {
    return MyCustomChip._(
      item: item,
      selected: false,
      color: Color(0xFFFCE7C1),
    );
  }

  factory MyCustomChip.assigned(BuildContext context, AssignedItem item) {
    return MyCustomChip._(
      item: item,
      selected: true,
      color: context.colorScheme.tertiaryContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Chip(item: item, selected: selected, color: color);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.item,
    required this.selected,
    required this.color,
  });

  final dynamic item;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (bool selected) {},
      selectedColor: selected ? color : null,
      backgroundColor: selected ? null : color,
      shape: const StadiumBorder(
        side: BorderSide(width: 0, color: Colors.transparent),
      ),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
