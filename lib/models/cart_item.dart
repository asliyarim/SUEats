import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});

  // Firestore dönüşüm metotları
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

// Global cart manager
class CartManager {
  static final List<CartItem> items = [
    CartItem(name: 'Margherita Pizza', price: 120.0),
    CartItem(name: 'Pepperoni Pizza', price: 145.0),
  ];

  static void addToCart(String name, double price) {
    // Check for existing item
    for (var item in items) {
      if (item.name == name) {
        item.quantity++;
        return;
      }
    }
    // Add new item
    items.add(CartItem(name: name, price: price));
  }

  static void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < items.length) {
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = newQuantity;
      }
    }
  }

  static double get subtotal => items.fold(
      0, (sum, item) => sum + (item.price * item.quantity));

  static final double deliveryFee = 15.0;
  static final double serviceFee = 5.0;

  static double get total => subtotal + deliveryFee + serviceFee;

  static void clearCart() {
    items.clear();
  }

  // Firebase'e kaydetmek için tüm sepeti Map olarak döndür
  static Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>> itemsList = items.map((item) => item.toMap()).toList();

    return {
      'items': itemsList,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'timestamp': Timestamp.now(),
    };
  }
}