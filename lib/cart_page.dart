import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CartPage({required this.cartItems, super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> cartItems;
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    cartItems = List<Map<String, dynamic>>.from(widget.cartItems);
    quantities = List<int>.filled(cartItems.length, 1);
  }

  void _increment(int index) {
    setState(() => quantities[index]++);
  }

  void _decrement(int index) {
    if (quantities[index] > 1) {
      setState(() => quantities[index]--);
    }
  }

  void _remove(int index) {
    setState(() {
      cartItems.removeAt(index);
      quantities.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      total += (cartItems[i]['price'] as num) * quantities[i];
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.asset(item['image'], width: 40, height: 40),
                  title: Text(item['name']),
                  subtitle: Text('₹${item['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _decrement(index),
                      ),
                      Text(quantities[index].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _increment(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _remove(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: ₹$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PaymentPage(total: total)),
                      );
                    },
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  final double total;
  const PaymentPage({required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total to pay: ₹$total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Payment logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
