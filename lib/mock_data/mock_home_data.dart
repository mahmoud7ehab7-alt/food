class CategoryModel {
  final String id;
  final String name;
  final String image;

  CategoryModel({required this.id, required this.name, required this.image});
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String image;
  final double rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.image,
    required this.rating,
  });
}

final List<CategoryModel> mockCategories = [
  CategoryModel(id: "1", name: "الكل", image: ""),
  CategoryModel(id: "2", name: "بيتزا", image: ""),
  CategoryModel(id: "3", name: "برجر", image: ""),
  CategoryModel(id: "4", name: "مشويات", image: ""),
  CategoryModel(id: "5", name: "حلويات", image: ""),
];

final List<ProductModel> mockFeaturedProducts = [
  ProductModel(
    id: "101",
    name: "بيف برجر كلاسيك",
    description: "لحم بقري مشوي مع الخضروات الطازجة والجبنة",
    price: 120.0,
    oldPrice: 150.0,
    image: "",
    rating: 4.8,
  ),
  ProductModel(
    id: "102",
    name: "بيتزا مارجريتا",
    description: "عجينة إيطالية رقيقة مع صلصة الطماطم والموزاريلا",
    price: 90.0,
    image: "",
    rating: 4.5,
  ),
  ProductModel(
    id: "103",
    name: "كباب وريش",
    description: "مشويات على الفحم مع السلطات والخبز الطازج",
    price: 250.0,
    oldPrice: 300.0,
    image: "",
    rating: 4.9,
  ),
];
