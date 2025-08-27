class ItemGroup {
  final String name;
  final double unitPrice;
  final int initialQuantity;
  int quantity;

  ItemGroup(this.name, this.unitPrice, this.quantity)
    : initialQuantity = quantity;

  ItemGroup copyWith({int? quantity}) =>
      ItemGroup(name, unitPrice, quantity ?? this.quantity);
}
