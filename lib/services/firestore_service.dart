// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> saveUser(String userId, Map<String, dynamic> userData) {
    return _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  // Delete user and associated data
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // Delete user's cart if exists
      await _firestore.collection('carts').doc(userId).delete();

      // Get user's orders
      final ordersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete user's orders
      final batch = _firestore.batch();
      for (var doc in ordersQuery.docs) {
        batch.delete(doc.reference);
      }

      if (ordersQuery.docs.isNotEmpty) {
        await batch.commit();
      }

      print('User with ID $userId deleted successfully from Firestore');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Restaurant operations
  Stream<QuerySnapshot> getRestaurants() {
    print("Getting restaurants from Firestore...");
    try {
      return _firestore.collection('restaurants').snapshots();
    } catch (e) {
      print("Error in getRestaurants method: $e");
      rethrow;
    }
  }

  Future<DocumentReference> addRestaurant(Map<String, dynamic> restaurantData) {
    return _firestore.collection('restaurants').add(restaurantData);
  }

  Future<void> updateRestaurant(String id, Map<String, dynamic> data) {
    return _firestore.collection('restaurants').doc(id).update(data);
  }

  Future<void> deleteRestaurant(String id) {
    return _firestore.collection('restaurants').doc(id).delete();
  }

  // Food item operations
  Stream<QuerySnapshot> getFoodItems(String restaurantId) {
    return _firestore
        .collection('foodItems')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('category')
        .snapshots();
  }

  Future<DocumentReference> addFoodItem(Map<String, dynamic> foodItemData) {
    return _firestore.collection('foodItems').add(foodItemData);
  }

  Future<void> updateFoodItem(String id, Map<String, dynamic> data) {
    return _firestore.collection('foodItems').doc(id).update(data);
  }

  Future<void> deleteFoodItem(String id) {
    return _firestore.collection('foodItems').doc(id).delete();
  }

  // Order operations
  Future<DocumentReference> createOrder(Map<String, dynamic> orderData) {
    return _firestore.collection('orders').add(orderData);
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrder(String id, Map<String, dynamic> data) {
    return _firestore.collection('orders').doc(id).update(data);
  }

  Future<void> deleteOrder(String id) {
    return _firestore.collection('orders').doc(id).delete();
  }

  // Cart operations
  Future<void> saveCart(String userId, Map<String, dynamic> cartData) {
    return _firestore.collection('carts').doc(userId).set(cartData);
  }

  Future<DocumentSnapshot> getCart(String userId) {
    return _firestore.collection('carts').doc(userId).get();
  }

  Future<void> clearCart(String userId) {
    return _firestore.collection('carts').doc(userId).delete();
  }

  // Menu operations - YENI EKLENEN METODLAR
  // Get menu items by restaurant ID
  Stream<QuerySnapshot> getMenuItems(String restaurantId) {
    print("Getting menu items for restaurant: $restaurantId");
    try {
      return _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menus')
          .snapshots();
    } catch (e) {
      print("Error in getMenuItems method: $e");
      rethrow;
    }
  }

  // Get a specific menu document
  Future<DocumentSnapshot> getMenu(String restaurantId, String menuId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .doc(menuId)
        .get();
  }

  // Add a menu item
  Future<DocumentReference> addMenuItem(String restaurantId, Map<String, dynamic> menuData) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .add(menuData);
  }

  // Update a menu item
  Future<void> updateMenuItem(String restaurantId, String menuId, Map<String, dynamic> data) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .doc(menuId)
        .update(data);
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String restaurantId, String menuId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .doc(menuId)
        .delete();
  }
}