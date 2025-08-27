import 'package:split_bill/src/models/diner.dart';

class AssignedItem {
  final String name;
  final double unitPrice;
  int quantity;
  Map<Diner, int> shares;

  AssignedItem(
    this.name,
    this.unitPrice,
    this.quantity, {
    Map<Diner, int>? shares,
  }) : shares = shares ?? {};

  double get totalPrice => unitPrice * quantity;
}
