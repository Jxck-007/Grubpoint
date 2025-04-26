import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_item.dart';

class FoodAvailabilityScreen extends StatefulWidget {
  const FoodAvailabilityScreen({super.key});

  @override
  State<FoodAvailabilityScreen> createState() => _FoodAvailabilityScreenState();
}

class _FoodAvailabilityScreenState extends State<FoodAvailabilityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updatePreparationTime(String foodId, int newTime) async {
    await _firestore.collection('food_items').doc(foodId).update({
      'preparationTime': newTime,
    });
  }

  Future<void> _updateAvailableQuantity(String foodId, int newQuantity) async {
    await _firestore.collection('food_items').doc(foodId).update({
      'availableQuantity': newQuantity,
    });
  }

  Future<void> _updateAvailability(String foodId, bool isAvailable) async {
    await _firestore.collection('food_items').doc(foodId).update({
      'isAvailable': isAvailable,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Availability'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('food_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final foodItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return FoodItem.fromMap(data);
          }).toList();

          return ListView.builder(
            itemCount: foodItems.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final foodItem = foodItems[index];
              final docId = snapshot.data!.docs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              foodItem.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodItem.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Price: \$${foodItem.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Preparation Time (minutes)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                text: foodItem.preparationTime.toString(),
                              ),
                              onSubmitted: (value) {
                                final newTime = int.tryParse(value);
                                if (newTime != null) {
                                  _updatePreparationTime(docId, newTime);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Available Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                text: foodItem.availableQuantity.toString(),
                              ),
                              onSubmitted: (value) {
                                final newQuantity = int.tryParse(value);
                                if (newQuantity != null) {
                                  _updateAvailableQuantity(docId, newQuantity);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available'),
                          Switch(
                            value: foodItem.isAvailable,
                            onChanged: (bool value) {
                              _updateAvailability(docId, value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 