class Medicine {
  final String? id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int stock;
  final String manufacturer;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.stock,
    required this.manufacturer,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Medicine to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'stock': stock,
      'manufacturer': manufacturer,
      'imageUrl': imageUrl ?? '',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Medicine from Firestore document
  factory Medicine.fromMap(String id, Map<String, dynamic> map) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      manufacturer: map['manufacturer'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // Create a copy with updated fields
  Medicine copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    int? stock,
    String? manufacturer,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      manufacturer: manufacturer ?? this.manufacturer,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

