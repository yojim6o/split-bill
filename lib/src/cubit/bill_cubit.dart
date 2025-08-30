import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/cubit/states/bill_state.dart';
import 'package:split_bill/src/models/assigned_item.dart';
import 'package:split_bill/src/models/diner.dart';
import 'package:split_bill/src/models/item_group.dart';

class BillCubit extends Cubit<BillState> {
  final List<ItemGroup> itemsList;
  BillCubit(this.itemsList)
      : super(
          BillState(
            originalItems: itemsList,
            auxItems: [],
            assignedItems: [],
          ),
        );

  void moveToAux(ItemGroup item) {
    if (item.quantity <= 0) return;
    final originalItems = List<ItemGroup>.from(state.originalItems);
    final auxItems = List<AssignedItem>.from(state.auxItems);

    final idx = originalItems.indexWhere((i) => i.name == item.name);
    originalItems[idx].quantity -= 1;

    final existing = auxItems.firstWhere(
      (i) => i.name == item.name && i.shares.isEmpty,
      orElse: () => AssignedItem(item.name, item.unitPrice, 0),
    );
    if (!auxItems.contains(existing)) {
      existing.quantity = 1;
      auxItems.add(existing);
    } else {
      existing.quantity += 1;
    }

    emit(state.copyWith(originalItems: originalItems, auxItems: auxItems));
  }

  void clearAux() {
    final originalItems = List<ItemGroup>.from(state.originalItems);
    final auxItems = List<AssignedItem>.from(state.auxItems);

    for (var aux in auxItems) {
      final idx = originalItems.indexWhere((o) => o.name == aux.name);
      originalItems[idx].quantity += aux.quantity;
    }

    emit(state.copyWith(originalItems: originalItems, auxItems: []));
  }

  void assignAuxToDiners(Map<Diner, int> dinerRatios) {
    final auxItems = List<AssignedItem>.from(state.auxItems);
    final assignedItems = List<AssignedItem>.from(state.assignedItems);

    for (var item in auxItems) {
      item.shares = {...dinerRatios};
      assignedItems.add(item);
    }

    emit(state.copyWith(auxItems: [], assignedItems: assignedItems));
  }

  void reset() {
    final originalItems = state.originalItems
        .map((i) => i..quantity = i.initialQuantity)
        .toList();
    emit(
      BillState(originalItems: originalItems, auxItems: [], assignedItems: []),
    );
  }
}
