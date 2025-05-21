import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.imageUrl = '',
    this.category = '',
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return MenuItem(
        id: doc.id,
        name: data['name'] ?? '',
        price: data['price'] is int
            ? (data['price'] as int).toDouble()
            : (data['price'] as num?)?.toDouble() ?? 0.0,
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        category: data['category'] ?? '',
      );
    } catch (e) {
      print("MenuItem.fromFirestore error: $e");
      // Return a default menu item to avoid app crash
      return MenuItem(
        id: doc.id,
        name: "Error: Could not convert data",
        price: 0.0,
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}