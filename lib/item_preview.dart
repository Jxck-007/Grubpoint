import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemPreviewPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemPreviewPage({required this.item, super.key});

  String get itemId => item['name'].toString().replaceAll(' ', '_').toLowerCase();

  @override
  Widget build(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    double userRating = 5.0;
    return Scaffold(
      appBar: AppBar(title: Text(item['name'])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(item['image'], fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(item['rating'].toString()),
                  ],
                ),
                const SizedBox(height: 8),
                Text('₹${item['price']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Add to Cart'),
                ),
                const SizedBox(height: 24),
                Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('items')
                        .doc(itemId)
                        .collection('reviews')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('No reviews yet.'));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: Icon(Icons.star, color: Colors.amber, size: 18),
                            title: Text(data['review'] ?? ''),
                            subtitle: Text('Rating: ${data['rating'] ?? 0}'),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Your Rating: '),
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: List.generate(5, (index) => IconButton(
                          icon: Icon(
                            index < userRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => userRating = index + 1.0);
                          },
                        )),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: reviewController,
                        decoration: const InputDecoration(hintText: 'Write a review...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final review = reviewController.text.trim();
                        if (review.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('items')
                              .doc(itemId)
                              .collection('reviews')
                              .add({
                            'review': review,
                            'rating': userRating,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          reviewController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review submitted!')),
                          );
                        }
                      },
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
