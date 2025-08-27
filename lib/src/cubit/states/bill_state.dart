import 'package:split_bill/src/models/assigned_item.dart';
import 'package:split_bill/src/models/item_group.dart';

class BillState {
  final List<ItemGroup> originalItems;
  final List<AssignedItem> auxItems;
  final List<AssignedItem> assignedItems;

  BillState({
    required this.originalItems,
    required this.auxItems,
    required this.assignedItems,
  });

  BillState copyWith({
    List<ItemGroup>? originalItems,
    List<AssignedItem>? auxItems,
    List<AssignedItem>? assignedItems,
  }) {
    return BillState(
      originalItems: originalItems ?? this.originalItems,
      auxItems: auxItems ?? this.auxItems,
      assignedItems: assignedItems ?? this.assignedItems,
    );
  }
}
