// lib/models/food_order.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class FoodOrder {  // Order yerine FoodOrder
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  FoodOrder({  // Yapıcı metodun adını da değiştirin
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory FoodOrder.fromFirestore(DocumentSnapshot doc) {  // Factory metodun adını da değiştirin
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // CartItem listesini Firestore'dan dönüştürme
    List<CartItem> cartItems = [];
    if (data['items'] != null) {
      for (var item in data['items']) {
        cartItems.add(
          CartItem(
            name: item['name'] ?? '',
            price: (item['price'] ?? 0.0).toDouble(),
            quantity: item['quantity'] ?? 1,
          ),
        );
      }
    }

    return FoodOrder(  // Burada da FoodOrder döndürün
      id: doc.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      items: cartItems,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      serviceFee: (data['serviceFee'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    // CartItem listesini Firestore'a uygun hale getirme
    List<Map<String, dynamic>> itemMaps = items.map((item) => {
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
    }).toList();

    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': itemMaps,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // copyWith metodunu da güncelleme
  FoodOrder copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? total,
    String? deliveryAddress,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return FoodOrder(  // Burada da FoodOrder döndürün
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}