import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../staff/food_availability_screen.dart';
import '../staff/order_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              _buildDashboardCard(
                context,
                'Manage Food Items',
                Icons.restaurant_menu,
                'Update menu items and availability',
                () {
                  _playHapticFeedback();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodAvailabilityScreen(),
                    ),
                  );
                },
                'assets/animations/food.json',
              ),
              _buildDashboardCard(
                context,
                'Order Management',
                Icons.receipt_long,
                'Track and manage orders',
                () {
                  _playHapticFeedback();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderManagementScreen(),
                    ),
                  );
                },
                'assets/animations/orders.json',
              ),
              _buildDashboardCard(
                context,
                'Analytics',
                Icons.analytics,
                'View sales and performance',
                () {
                  _playHapticFeedback();
                  // TODO: Implement analytics screen
                },
                'assets/animations/analytics.json',
              ),
              _buildDashboardCard(
                context,
                'Settings',
                Icons.settings,
                'Configure app settings',
                () {
                  _playHapticFeedback();
                  // TODO: Implement settings screen
                },
                'assets/animations/settings.json',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
    String animationPath,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                animationPath,
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 