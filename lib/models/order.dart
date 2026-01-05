class MedicineOrder {
  final String? id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'processing', 'completed', 'cancelled'
  final ShippingInfo shippingInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MedicineOrder({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    required this.shippingInfo,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'shippingInfo': shippingInfo.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MedicineOrder.fromMap(String id, Map<String, dynamic> map) {
    return MedicineOrder(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      shippingInfo: ShippingInfo.fromMap(
        map['shippingInfo'] as Map<String, dynamic>,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

class OrderItem {
  final String medicineId;
  final String medicineName;
  final double price;
  final int quantity;

  OrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  double get subtotal => price * quantity;
}

class ShippingInfo {
  final String fullName;
  final String phone;
  final String address;
  final String? notes;

  ShippingInfo({
    required this.fullName,
    required this.phone,
    required this.address,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'notes': notes ?? '',
    };
  }

  factory ShippingInfo.fromMap(Map<String, dynamic> map) {
    return ShippingInfo(
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'],
    );
  }
}

