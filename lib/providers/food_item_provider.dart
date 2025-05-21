import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../services/firestore_service.dart';

class FoodItemProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedRestaurantId;

  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectRestaurant(String restaurantId) {
    if (_selectedRestaurantId != restaurantId) {
      _selectedRestaurantId = restaurantId;
      fetchFoodItems(restaurantId);
    }
  }

  Future<void> fetchFoodItems(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _firestoreService.getFoodItems(restaurantId).listen((snapshot) {
        _foodItems = snapshot.docs.map((doc) {
          return FoodItem.fromFirestore(doc);
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

  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      await _firestoreService.addFoodItem(foodItem.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      await _firestoreService.updateFoodItem(foodItem.id, foodItem.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      await _firestoreService.deleteFoodItem(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}