import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/cubit/bill_cubit.dart';
import 'package:split_bill/src/cubit/states/bill_state.dart';
import 'package:split_bill/src/models/assigned_item.dart';
import 'package:split_bill/src/models/diner.dart';
import 'package:split_bill/src/models/item_group.dart';
import 'package:split_bill/src/utils/extensions.dart';
import 'package:split_bill/src/widgets/my_custom_chip.dart';
import 'package:split_bill/src/widgets/dragging_chip.dart';

class BillSplitterPage extends StatefulWidget {
  const BillSplitterPage({super.key});

  @override
  _BillSplitterPageState createState() => _BillSplitterPageState();
}

class _BillSplitterPageState extends State<BillSplitterPage> {
  Diner? selectedDiner;
  final diners = [Diner("Juan"), Diner("Pedro"), Diner("Ramón")];

  double dinerTotal(AssignedItem item, Diner diner) {
    final totalRatio = item.shares.values.fold(0, (a, b) => a + b);
    if (totalRatio == 0) return 0;
    return (item.shares[diner]! / totalRatio) * item.totalPrice;
  }

  List<Widget> assignedItemsForDiner(
    Diner diner,
    List<AssignedItem> assignedItems,
  ) {
    return assignedItems.where((item) => item.shares.containsKey(diner)).map((
      item,
    ) {
      final isShared = item.shares.length > 1;
      final sharePrice = dinerTotal(item, diner);
      return Text(
        isShared
            ? "${item.name} ×${item.quantity} - compartido: \$${sharePrice.toStringAsFixed(2)}"
            : "${item.name} ×${item.quantity}: \$${sharePrice.toStringAsFixed(2)}",
      );
    }).toList();
  }

  void showAssignDialog(
    BuildContext parentContext,
    List<AssignedItem> itemsToAssign,
    List<Diner> diners,
  ) {
    final cubit = parentContext.read<BillCubit>();

    final Map<Diner, bool> checked = {for (var d in diners) d: false};
    final Map<Diner, TextEditingController> controllers = {
      for (var d in diners) d: TextEditingController(text: "1"),
    };

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Asignar items a comensales"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: diners.map((d) {
                  return Row(
                    children: [
                      Checkbox(
                        value: checked[d],
                        onChanged: (val) {
                          setState(() {
                            checked[d] = val ?? false;
                          });
                        },
                      ),
                      Expanded(child: Text(d.name)),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: controllers[d],
                          keyboardType: TextInputType.number,
                          enabled: checked[d] == true,
                          decoration: const InputDecoration(hintText: "ratio"),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final Map<Diner, int> ratios = {};
                for (var d in diners) {
                  if (checked[d] == true) {
                    final val = int.tryParse(controllers[d]!.text) ?? 1;
                    if (val > 0) ratios[d] = val;
                  }
                }
                if (ratios.isNotEmpty) {
                  cubit.assignAuxToDiners(ratios);
                  Navigator.pop(context);
                }
              },
              child: const Text("Asignar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BillCubit, BillState>(
        builder: (context, state) {
          final totalRemaining = state.originalItems.fold(
            0.0,
            (sum, i) => sum + i.unitPrice * i.quantity,
          );
          final totalAssigned = state.assignedItems.fold(
            0.0,
            (sum, i) => sum + i.totalPrice,
          );

          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Text(
                      "Total por asignar: ${totalRemaining.toStringAsFixed(2)}€",
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 4,
                          children: state.originalItems
                              .where((i) => i.quantity > 0)
                              .map((item) {
                            return LongPressDraggable<ItemGroup>(
                              data: item,
                              feedback: DraggingChip(item: item),
                              child: MyCustomChip.unassigned(
                                context,
                                item,
                              ),
                              onDragCompleted: () =>
                                  context.read<BillCubit>().moveToAux(item),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Arrastra items aquí"),
                        const Icon(Icons.arrow_downward_rounded),
                      ],
                    ),
                    const Divider(height: 10),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: DragTarget<ItemGroup>(
                          builder: (context, candidateData, rejectedData) {
                            if (state.auxItems.isEmpty) {
                              return const Center(child: Text("Vacía"));
                            }
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 4,
                                  children: state.auxItems
                                      .map(
                                        (item) => MyCustomChip.assigned(
                                          context,
                                          item,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: state.auxItems.isEmpty
                                ? null
                                : () => showAssignDialog(
                                      context,
                                      state.auxItems.toList(),
                                      diners,
                                    ),
                            child: const Text("Asignar items a..."),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: state.auxItems.isEmpty
                                ? null
                                : () => context.read<BillCubit>().clearAux(),
                            child: const Text("Limpiar"),
                          ),
                        ],
                      ),
                    ),
                    //Text("Total asignado: \${totalAssigned.toStringAsFixed(2)€}"),
                  ],
                ),
                /*  DraggableScrollableSheet(
                    initialChildSize: 0.06,
                    minChildSize: 0.06,
                    maxChildSize: 0.5,
                    snapSizes: const [0.06],
                    snap: true,
                    expand: true,
                    builder:
                        (
                          BuildContext context,
                          ScrollController scrollController,
                        ) {
                          return Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black),
                          );
                        },
                  ), */
                /*
                  Expanded(
  flex: 1,
  child: Row(
    children: [
      Column(
        children: diners.map((d) {
          final isSelected = selectedDiner == d;
          return ListTile(
            title: Text(d.name),
            selected: isSelected,
            onTap: () {
              setState(() {
                selectedDiner = d;
              });
            },
          );
        }).toList(),
      ),

      Expanded(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[100],
          child: selectedDiner == null
              ? const Center(child: Text("Selecciona un comensal"))
              : ListView(
                  children: context.read<BillCubit>().state.assignedItems
                      .where((item) => item.shares.containsKey(selectedDiner))
                      .map((item) {
                    final isShared = item.shares.length > 1;
                    final totalRatio = item.shares.values.fold(0, (a, b) => a + b);
                    final sharePrice = totalRatio == 0
                        ? 0
                        : (item.shares[selectedDiner]! / totalRatio) * item.totalPrice;
                    return ListTile(
                      title: Text(isShared
                          ? "${item.name} ×${item.quantity} - compartido: \$${sharePrice.toStringAsFixed(2)}"
                          : "${item.name} ×${item.quantity}: \$${sharePrice.toStringAsFixed(2)}"),
                    );
                  }).toList(),
                ),
        ),
      ),
    ],
  ),
),
 */
              ],
            ),
          );
        },
      ),
    );
  }
}
