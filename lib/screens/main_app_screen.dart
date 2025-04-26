import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'restaurant_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  final List<Widget> _screens = [
    const RestaurantListScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Row(
          children: [
            if (isWeb)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  _playHapticFeedback();
                  setState(() => _selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.restaurant),
                    selectedIcon: const Icon(Icons.restaurant),
                    label: const Text('Restaurants'),
                  ),
                  NavigationRailDestination(
                    icon: Badge(
                      label: Text(cartProvider.itemCount.toString()),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    selectedIcon: Badge(
                      label: Text(cartProvider.itemCount.toString()),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    label: const Text('Cart'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person),
                    selectedIcon: const Icon(Icons.person),
                    label: const Text('Profile'),
                  ),
                ],
              ),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isWeb
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                _playHapticFeedback();
                setState(() => _selectedIndex = index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.restaurant),
                  label: 'Restaurants',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartProvider.itemCount > 0,
                    label: Text(cartProvider.itemCount.toString()),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      floatingActionButton: cartProvider.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _playHapticFeedback();
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Badge(
                isLabelVisible: cartProvider.itemCount > 0,
                label: Text(cartProvider.itemCount.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
            )
          : null,
    );
  }
} 