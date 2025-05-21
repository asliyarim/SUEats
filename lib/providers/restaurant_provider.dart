// lib/providers/restaurant_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../services/firestore_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RestaurantProvider() {
    print("RestaurantProvider initialized");
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Restoranlar için Firestore dinlemeye başlanıyor...");

      _firestoreService.getRestaurants().listen((snapshot) {
        print("Firestore'dan ${snapshot.docs.length} restoran alındı");

        _restaurants = snapshot.docs.map((doc) {
          try {
            print("Restoran dönüştürülüyor: ${doc.id}");
            final restaurant = Restaurant.fromFirestore(doc);
            print("Restoran başarıyla dönüştürüldü: ${restaurant.name}");
            return restaurant;
          } catch (e) {
            print("Restoran dönüştürme hatası (${doc.id}): $e");
            rethrow;
          }
        }).toList();

        _isLoading = false;
        print("Toplam ${_restaurants.length} restoran listeye eklendi");
        notifyListeners();

      }, onError: (e) {
        print("Firestore dinleme hatası: $e");
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("fetchRestaurants genel hatası: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRestaurant(Restaurant restaurant) async {
    try {
      await _firestoreService.addRestaurant(restaurant.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateRestaurant(Restaurant restaurant) async {
    try {
      await _firestoreService.updateRestaurant(restaurant.id, restaurant.toFirestore());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteRestaurant(String id) async {
    try {
      await _firestoreService.deleteRestaurant(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}