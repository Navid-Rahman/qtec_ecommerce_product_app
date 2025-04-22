import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String resourceId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final String category;
  @HiveField(6)
  final String image;
  @HiveField(7)
  final double rating;

  ProductModel({
    required this.id,
    required this.resourceId,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  }) : super(
         id: id,
         title: title,
         price: price,
         description: description,
         category: category,
         image: image,
         rating: rating,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      resourceId: json['id'].toString(), // Use id as resourceId for simplicity
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: (json['rating']['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resourceId': resourceId,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {'rate': rating},
    };
  }
}
