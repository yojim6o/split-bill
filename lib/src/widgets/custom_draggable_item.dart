import 'package:flutter/material.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/utils/extensions.dart';
import 'package:split_bill/src/widgets/animated_switcher_text.dart';

class CustomDraggableItem extends StatelessWidget {
  const CustomDraggableItem({super.key, required this.itemGroup});

  final ItemGroup itemGroup;

  @override
  Widget build(BuildContext context) {
    ValueNotifier listenableValue = ValueNotifier(itemGroup.initialQuantity);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        RawChip(
          shape: StadiumBorder(),
          label: Text(itemGroup.name),
          elevation: 1,
          shadowColor: context.colorScheme.secondary,
          side: BorderSide(color: Colors.transparent),
        ),
        Material(
          color: Colors.transparent,
          child: ValueListenableBuilder(
            valueListenable: listenableValue,
            builder: (context, value, child) => Row(
              spacing: 8,
              children: [
                _CustomInkwell(
                    callback: () => listenableValue.value++, icon: Icons.add),
                AnimatedSwitcherText(
                    uKey: listenableValue.value,
                    value: listenableValue.value.toString()),
                _CustomInkwell(
                    callback: () {
                      if (listenableValue.value < 2) {
                        return;
                      }
                      listenableValue.value--;
                    },
                    icon: Icons.remove),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _CustomInkwell extends StatelessWidget {
  const _CustomInkwell({required this.callback, required this.icon});

  final Function callback;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 50,
      borderRadius: BorderRadius.circular(50),
      splashColor: context.colorScheme.tertiaryFixed,
      onTap: () => callback(),
      child: Icon(
        icon,
        size: 36,
        color: context.colorScheme.onTertiaryContainer,
      ),
    );
  }
}
