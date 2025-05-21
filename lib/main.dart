// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/food_item_provider.dart';
import 'providers/order_provider.dart';
import 'providers/menu_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase başarıyla başlatıldı");


    try {
      final testCollection = FirebaseFirestore.instance.collection('restaurants');
      final testQuery = await testCollection.limit(1).get();
      print("Firestore bağlantı testi başarılı: ${testQuery.docs.length} restoran bulundu");

      if (testQuery.docs.isEmpty) {
        print("Uyarı: 'restaurants' koleksiyonu boş görünüyor. Firestore'da veri olduğundan emin olun!");
      }
    } catch (e) {
      print("Firestore bağlantı testi başarısız: $e");
    }

  } catch (e) {
    print("Firebase başlatma hatası: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: MaterialApp(
        title: 'SuEats',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}