import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_order.dart';  // order.dart yerine food_order.dart import edin
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<FoodOrder> _orders = [];  // Order yerine FoodOrder
  bool _isLoading = false;
  String? _error;

  List<FoodOrder> get orders => _orders;  // Getter da FoodOrder döndürmeli
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _firestoreService.getUserOrders(userId).listen((snapshot) {
        _orders = snapshot.docs.map((doc) {
          return FoodOrder.fromFirestore(doc);  // Order.fromFirestore yerine FoodOrder.fromFirestore
        }).toList();

        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(FoodOrder order) async {  // Order yerine FoodOrder
    try {
      await _firestoreService.createOrder(order.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOrder(FoodOrder order) async {  // Order yerine FoodOrder
    try {
      await _firestoreService.updateOrder(order.id, order.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _firestoreService.deleteOrder(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}