// lib/screens/restaurant_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'restaurant_listing_screen.dart';
import 'profile_screen.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantMenuScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<MenuItem>> _categorizedItems = {};
  final List<String> _categories = [];

  @override
  void initState() {
    super.initState();

    // Load menu items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("RestaurantMenuScreen: Setting restaurant ID: ${widget.restaurantId}");
      Provider.of<MenuProvider>(context, listen: false).selectRestaurant(widget.restaurantId);
    });

    _tabController = TabController(length: 1, vsync: this); // Start with 1, will update later
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(String name, double price) {
    // Use CartManager until CartProvider is fully implemented
    CartManager.addToCart(name, price);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to cart'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Menu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (menuProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${menuProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      menuProvider.fetchMenuItems(widget.restaurantId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (menuProvider.menuItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.grey, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No menu items found for this restaurant',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Categorize menu items
          _categorizedItems.clear();
          _categories.clear();

          for (var menuItem in menuProvider.menuItems) {
            final category = menuItem.category.isNotEmpty ? menuItem.category : 'Other';

            if (!_categorizedItems.containsKey(category)) {
              _categorizedItems[category] = [];
              _categories.add(category);
            }

            _categorizedItems[category]!.add(menuItem);
          }

          // Update tab controller if categories count changed
          if (_tabController.length != _categories.length && _categories.isNotEmpty) {
            _tabController.dispose();
            _tabController = TabController(
              length: _categories.length,
              vsync: this,
            );
          }

          return Column(
            children: [
              if (_categories.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: _categories.map((category) => Tab(text: category)).toList(),
                ),
              Expanded(
                child: _categories.isEmpty
                    ? const Center(child: Text('No categories available'))
                    : TabBarView(
                  controller: _tabController,
                  children: _categories.map((category) {
                    final categoryItems = _categorizedItems[category] ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categoryItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = categoryItems[index];
                        return _buildMenuItem(
                          menuItem.name,
                          menuItem.description,
                          menuItem.price,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Restaurant related
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RestaurantListingScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(String name, String description, double price) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₺${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(name, price),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}