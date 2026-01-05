import 'medicine.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({
    required this.medicine,
    this.quantity = 1,
  });

  double get totalPrice => medicine.price * quantity;

  CartItem copyWith({
    Medicine? medicine,
    int? quantity,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }
}

