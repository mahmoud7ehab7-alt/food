class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String image;
  final double rating;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.image,
    required this.rating,
    this.isFeatured = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      categoryId: (map['categoryId'] ?? '').toString().trim(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      oldPrice: map['oldPrice']?.toDouble(),
      image: (map['image'] ?? '').toString().trim(),
      rating: (map['rating'] ?? 0).toDouble(),
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
      'rating': rating,
      'isFeatured': isFeatured,
    };
  }
}
