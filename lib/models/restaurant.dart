// lib/models/restaurant.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> cuisineTypes; // Dikkat: Firebase'de 'cuisine' adı altında tek bir string var
  final double rating;
  final int deliveryTime;
  final double minOrder;
  final double distance;
  final String createdBy;
  final DateTime createdAt;

  Restaurant({
    required this.id,
    required this.name,
    this.imageUrl = '',
    required this.cuisineTypes,
    required this.rating,
    required this.deliveryTime,
    required this.minOrder,
    this.distance = 0.0,
    this.createdBy = '',
    required this.createdAt,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print("Dönüştürülüyor: Restaurant document: $data");

      // Tek bir string 'cuisine' alanını liste haline getir
      List<String> cuisineList = [];
      if (data['cuisine'] != null) {
        cuisineList.add(data['cuisine'].toString());
      }

      return Restaurant(
        id: doc.id,
        name: data['name'] ?? '',
        imageUrl: '', // Firebase'de görünmüyor, boş string kullan
        cuisineTypes: cuisineList, // Tek bir string'i liste olarak kullan
        rating: data['rating'] != null
            ? (data['rating'] is int ? (data['rating'] as int).toDouble() : data['rating'] as double)
            : 0.0,
        deliveryTime: data['deliveryTime'] != null
            ? (data['deliveryTime'] is String
            ? int.tryParse(data['deliveryTime'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
            : (data['deliveryTime'] as num).toInt())
            : 0,
        minOrder: data['minOrder'] != null
            ? (data['minOrder'] is int ? (data['minOrder'] as int).toDouble() : data['minOrder'] as double)
            : 0.0,
        distance: 0.0, // Firebase'de görünmüyor, varsayılan değer kullan
        createdBy: '', // Firebase'de görünmüyor, varsayılan değer kullan
        createdAt: DateTime.now(), // Firebase'de görünmüyor, şu anki zamanı kullan
      );
    } catch (e) {
      print("Restaurant.fromFirestore hatası: $e");
      print("Hata ayrıntıları - doc.id: ${doc.id}, data: ${doc.data()}");
      // Hata durumunda varsayılan bir restoran döndür (uygulama çökmemesi için)
      return Restaurant(
        id: doc.id,
        name: "Hata: Veri dönüştürülemedi",
        imageUrl: '',
        cuisineTypes: [],
        rating: 0.0,
        deliveryTime: 0,
        minOrder: 0.0,
        distance: 0.0,
        createdBy: '',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    // Firebase'e gönderirken liste yerine tek bir string gönder
    String cuisine = cuisineTypes.isNotEmpty ? cuisineTypes[0] : '';

    return {
      'name': name,
      'cuisine': cuisine,
      'rating': rating,
      'deliveryTime': deliveryTime.toString() + " min",
      'minOrder': minOrder,
    };
  }
}