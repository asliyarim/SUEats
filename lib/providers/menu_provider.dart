import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

class MenuProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedRestaurantId;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedRestaurantId => _selectedRestaurantId;

  // Set the restaurant ID and fetch menu items
  void selectRestaurant(String restaurantId) {
    if (_selectedRestaurantId != restaurantId) {
      _selectedRestaurantId = restaurantId;
      fetchMenuItems(restaurantId);
    }
  }

  // Fetch menu items for a restaurant
  Future<void> fetchMenuItems(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Fetching menu items for restaurant: $restaurantId");

      _firestoreService.getMenuItems(restaurantId).listen((snapshot) {
        print("Firestore returned ${snapshot.docs.length} menu items");

        _menuItems = snapshot.docs.map((doc) {
          try {
            print("Converting menu item: ${doc.id}");
            final menuItem = MenuItem.fromFirestore(doc);
            print("Successfully converted menu item: ${menuItem.name}");
            return menuItem;
          } catch (e) {
            print("Menu item conversion error (${doc.id}): $e");
            rethrow;
          }
        }).toList();

        _isLoading = false;
        print("Added ${_menuItems.length} menu items to the list");
        notifyListeners();

      }, onError: (e) {
        print("Firestore stream error: $e");
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("fetchMenuItems general error: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a menu item
  Future<void> addMenuItem(MenuItem menuItem) async {
    if (_selectedRestaurantId == null) {
      _error = "No restaurant selected";
      notifyListeners();
      return;
    }

    try {
      await _firestoreService.addMenuItem(
        _selectedRestaurantId!,
        menuItem.toFirestore(),
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update a menu item
  Future<void> updateMenuItem(MenuItem menuItem) async {
    if (_selectedRestaurantId == null) {
      _error = "No restaurant selected";
      notifyListeners();
      return;
    }

    try {
      await _firestoreService.updateMenuItem(
        _selectedRestaurantId!,
        menuItem.id,
        menuItem.toFirestore(),
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String menuItemId) async {
    if (_selectedRestaurantId == null) {
      _error = "No restaurant selected";
      notifyListeners();
      return;
    }

    try {
      await _firestoreService.deleteMenuItem(
        _selectedRestaurantId!,
        menuItemId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}