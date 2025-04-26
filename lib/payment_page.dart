import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  const PaymentPage({required this.totalAmount, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod;
  bool _isProcessing = false;

  final List<Map<String, String>> paymentMethods = [
    {'name': 'GPay', 'icon': 'assets/gpay.png'},
    {'name': 'PhonePe', 'icon': 'assets/phonepe.png'},
    {'name': 'Net Banking', 'icon': 'assets/netbanking.png'},
    {'name': 'Cash on Delivery', 'icon': 'assets/cash.png'},
  ];

  final AudioPlayer audioPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    audioPlayer.play(AssetSource('your_audio_file.mp3'));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  void _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate payment
    setState(() => _isProcessing = false);
    _playSuccessSound();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(total: widget.totalAmount),
      ),
    );
  }

  Future<void> _playSuccessSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('success_sound.mp3')); // Make sure this audio file exists in your assets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/LOGO.png', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: ₹${widget.totalAmount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 24),
                const Text('Select Payment Method:', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                const SizedBox(height: 16),
                ...paymentMethods.map((method) => ListTile(
                      leading: method['icon'] != null ? Image.asset(method['icon']!, width: 32, height: 32) : null,
                      title: Text(method['name']!, style: const TextStyle(color: Colors.deepPurple)),
                      trailing: Radio<String>(
                        value: method['name']!,
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value),
                      ),
                      onTap: () => setState(() => _selectedMethod = method['name']),
                    )),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selectedMethod == null || _isProcessing ? null : _pay,
                    child: _isProcessing
                        ? Column(
                            children: [
                              const SizedBox(height: 8),
                              const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              const SizedBox(height: 8),
                              const Text('Processing Payment...', style: TextStyle(color: Colors.white)),
                            ],
                          )
                        : const Text('Pay Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTrackingPage extends StatelessWidget {
  final double total;
  const OrderTrackingPage({required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy order status for demonstration
    final List<String> statuses = [
      'Order Placed',
      'Preparing',
      'Ready for Pickup',
      'Completed',
    ];
    int currentStatus = 1; // You can update this dynamically
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Total: ₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...List.generate(statuses.length, (i) => Row(
              children: [
                Icon(
                  i <= currentStatus ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: i <= currentStatus ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(statuses[i], style: TextStyle(fontSize: 18, color: i <= currentStatus ? Colors.green : Colors.grey)),
              ],
            )),
            const SizedBox(height: 32),
            if (currentStatus < statuses.length - 1)
              const Text('Your order is being prepared...', style: TextStyle(fontSize: 16)),
            if (currentStatus == statuses.length - 1)
              const Text('Order completed! Enjoy your meal!', style: TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
