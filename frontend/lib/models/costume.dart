class Costume {
  final String? id;
  final String description;
  final double price;
  final String imageUrl;
  final String? sellerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isReserved;


  Costume({
    this.id,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.sellerId,
    required this.createdAt,
    this.updatedAt,
    required this.isReserved,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Costume.fromMap(String id, Map<String, dynamic> map) {
    return Costume(
      id: id,
      description: map['description'] ?? '',
      price: double.parse(map['price']?.toString() ?? "0.0"),
      imageUrl: map['image_url'] ?? '',
      sellerId: map['seller_id']?.toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,

      isReserved: (map['is_reserved'] ?? 0) == 1,
    );
  }


  Costume copyWith({
    String? id,
    String? description,
    double? price,
    String? imageUrl,
    String? sellerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isReserved,
  }) {
    return Costume(
      id: id ?? this.id,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReserved: isReserved ?? this.isReserved,
    );
  }
}

