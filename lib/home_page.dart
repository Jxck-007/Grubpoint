import 'package:flutter/material.dart';
import 'package:rit_grubpoint/cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'gemini_chat_page.dart';

class HomeMenuPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  const HomeMenuPage({super.key, this.onToggleTheme});
  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> categories = [
    'Noodles',
    'Pasta',
    'Drink',
    'Dessert',
    'Breakfast',
    'Lunch',
    'Our Pick',
  ];
  final List<String> categoryImages = [
    'assets/noodles.png',
    'assets/pasta.png',
    'assets/sodas.png',
    'assets/dessert.png',
    'assets/noodles.png',
    'assets/pasta.png',
    'assets/dessert.png',
  ];
  int selectedCategory = 0;
  final List<Map<String, dynamic>> cartItems = [];
  String searchQuery = '';
  Set<String> favoriteItems = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? profileImageUrl;
  bool _uploadingImage = false;

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    setState(() => _uploadingImage = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
      await ref.putData(await picked.readAsBytes());
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'profileImageUrl': url}, SetOptions(merge: true));
      setState(() => profileImageUrl = url);
      showAppSnackBar(context, 'Profile picture updated!');
    } catch (e) {
      showAppSnackBar(context, 'Failed to upload image', color: Colors.red);
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      profileImageUrl = doc.data()?['profileImageUrl'];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _loadProfileImage();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteItems = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  // Define menu categories and items
  // Example: {'name': 'Samosa', 'price': 12, 'description': 'A crispy and spicy deep-fried snack filled with potatoes and peas.'},
  final List<Map<String, dynamic>> menuCategories = [
    {
      'name': 'Snacks',
      'image': 'assets/dessert.png',
      'items': [
        {'name': 'Samosa', 'price': 12, 'description': 'A crispy and spicy deep-fried snack filled with potatoes and peas.'},
        {'name': 'Veg Cutlet', 'price': 15, 'description': 'A crunchy patty made with mixed vegetables and spices.'},
        {'name': 'Aloo S/W Cutlet', 'price': 15, 'description': 'Potato cutlet served in a sandwich style.'},
        {'name': 'Egg Cutlet', 'price': 20, 'description': 'A savory cutlet made with boiled eggs and spices.'},
        {'name': 'Channa Masala', 'price': 30, 'description': 'Spicy chickpea curry, a popular Indian snack.'},
        {'name': 'Kachori', 'price': 20, 'description': 'A round, deep-fried snack stuffed with spicy lentils.'},
        {'name': 'Pani Poori', 'price': 30, 'description': 'Crispy puris filled with tangy and spicy flavored water.'},
        {'name': 'Bhel Poori', 'price': 40, 'description': 'A crunchy mixture of puffed rice, vegetables, and tangy sauces.'},
        {'name': 'Bread Paneer Pakkoda', 'price': 20, 'description': 'Bread slices stuffed with paneer, dipped in batter and fried.'},
        {'name': 'Gulab Jamun', 'price': 20, 'description': 'Soft, deep-fried balls soaked in sweet sugar syrup.'},
        {'name': 'Samosa Chenna', 'price': 40, 'description': 'Samosa served with spicy chenna (chickpea curry).'},
        {'name': 'Dahi Puri', 'price': 40, 'description': 'Puris filled with yogurt, chutneys, and spices.'},
        {'name': 'Veg Frankie', 'price': 35, 'description': 'A soft roll stuffed with spiced vegetables.'},
        {'name': 'Egg Frankie', 'price': 40, 'description': 'A soft roll filled with egg and spices.'},
        {'name': 'Paneer Frankie', 'price': 50, 'description': 'A roll stuffed with paneer and flavorful spices.'},
        {'name': 'Half Boil / Boiled Egg', 'price': 10, 'description': 'Eggs boiled to perfection, served hot.'},
        {'name': 'Omlate', 'price': 15, 'description': 'Classic Indian-style omelette with onions and chilies.'},
        {'name': 'Bread Omlate', 'price': 35, 'description': 'Omelette served between slices of bread.'},
        {'name': 'Veg S.W', 'price': 25, 'description': 'Vegetable sandwich with fresh veggies and chutney.'},
        {'name': 'Cheese SW', 'price': 40, 'description': 'Cheese sandwich, grilled to perfection.'},
        {'name': 'Choco Cheese S/W', 'price': 50, 'description': 'A sweet and savory sandwich with chocolate and cheese.'},
        {'name': 'Egg Podimass', 'price': 30, 'description': 'Scrambled eggs cooked with South Indian spices.'},
        {'name': 'Gobi Fry', 'price': 40, 'description': 'Crispy fried cauliflower tossed in spices.'},
        {'name': 'Veg Maggi', 'price': 30, 'description': 'Instant noodles cooked with vegetables and masala.'},
        {'name': 'Egg Maggi', 'price': 40, 'description': 'Maggi noodles cooked with eggs and spices.'},
        {'name': 'Vig Pizza', 'price': 50, 'description': 'Vegetarian pizza with assorted toppings.'},
        {'name': 'Cheese Pizza', 'price': 70, 'description': 'Pizza topped generously with cheese.'},
        {'name': 'Momos - Veg', 'price': 60, 'description': 'Steamed dumplings filled with vegetables.'},
        {'name': 'Momos - Paneer', 'price': 70, 'description': 'Steamed dumplings filled with paneer.'},
        {'name': 'Potato Wedges', 'price': 60, 'description': 'Crispy potato wedges, lightly spiced.'},
        {'name': 'Smilly Potato', 'price': 50, 'description': 'Potato snacks shaped like smileys.'},
        {'name': 'Veg Nuggets', 'price': 50, 'description': 'Crunchy nuggets made with mixed vegetables.'},
        {'name': 'French Fries', 'price': 50, 'description': 'Classic deep-fried potato fries.'},
        {'name': 'Peri Peri Fries', 'price': 60, 'description': 'French fries tossed in spicy peri peri seasoning.'},
        {'name': 'Lays', 'price': 20, 'description': 'Popular potato chips in various flavors.'},
        {'name': 'Kurkure', 'price': 20, 'description': 'Crunchy, spicy corn-based snack.'},
        {'name': 'Sundal', 'price': 15, 'description': 'South Indian snack made with boiled legumes and coconut.'},
        {'name': 'Sweet Corn', 'price': 20, 'description': 'Steamed sweet corn with butter and spices.'},
        {'name': 'Biscuit', 'price': 10, 'description': 'Assorted biscuits, perfect for tea time.'},
        {'name': 'Bajji', 'price': 20, 'description': 'Vegetables dipped in gram flour batter and deep-fried.'},
      ],
    },
    {
      'name': 'Lunch',
      'image': 'assets/pasta.png',
      'items': [
        {'name': 'Meals', 'price': 60},
        {'name': 'Sambar Rice', 'price': 35},
        {'name': 'Curd Rice', 'price': 30},
        {'name': 'Veg Briyani', 'price': 55},
        {'name': 'Veg Fried Rice', 'price': 50},
        {'name': 'Egg Fried Rice', 'price': 60},
        {'name': 'Gobi Egg Rice', 'price': 70},
        {'name': 'Gobi Rice', 'price': 60},
        {'name': 'Veg Pasta', 'price': 35},
        {'name': 'Egg Pasta', 'price': 40},
        {'name': 'Gobi Pasta', 'price': 40},
        {'name': 'Egg Gobi Pasta', 'price': 60},
        {'name': 'Chola Poori', 'price': 40},
        {'name': 'Gobi Noodles', 'price': 50},
        {'name': 'Egg Gobi Noodles', 'price': 70},
        {'name': 'Egg Noodles', 'price': 50},
        {'name': 'Veg Noodles', 'price': 35},
        {'name': 'Chilly Gobi', 'price': 50},
        {'name': 'Chilly Parota', 'price': 50},
        {'name': 'Parcel', 'price': 5},
        {'name': 'Lemon Rice', 'price': 30},
        {'name': 'Chapathi Set', 'price': 25},
        {'name': 'Parotta Set', 'price': 30},
        {'name': 'Egg Gravy', 'price': 15},
        {'name': 'Mushroom Briyani', 'price': 60},
        {'name': 'Chilly Paneer', 'price': 50},
        {'name': 'Chilly Mushroom', 'price': 50},
      ],
    },
    {
      'name': 'Bakery',
      'image': 'assets/dessert.png',
      'items': [
        {'name': 'Puting Cake', 'price': 25},
        {'name': 'Brownie Cake', 'price': 35},
        {'name': 'Lava Cake', 'price': 45},
        {'name': 'Chocolate Mouffin', 'price': 30},
        {'name': 'Mousse Cake', 'price': 35},
        {'name': 'Ice Cake', 'price': 40},
        {'name': 'Choco Truffle', 'price': 45},
        {'name': 'Bread Packet', 'price': 45},
        {'name': 'Apple Mousse Cake', 'price': 40},
        {'name': 'Choco Mousse Cake', 'price': 50},
        {'name': 'Veg Puffs', 'price': 15},
        {'name': 'Egg Puffs', 'price': 20},
        {'name': 'Birthday Cake-700 -1kg', 'price': 700},
        {'name': 'Birthday Cake-350 -1/2kg', 'price': 350},
        {'name': 'Birthday Cake-800 -1kg', 'price': 800},
        {'name': 'Birthday Cake-400 -1/2kg', 'price': 400},
        {'name': 'Oats Cookies', 'price': 25},
        {'name': 'Choco Chips', 'price': 25},
        {'name': 'Bun Butter Jam', 'price': 20},
        {'name': 'Pav Bajji', 'price': 40},
        {'name': 'Veg Burger', 'price': 50},
      ],
    },
    {
      'name': 'Breakfast',
      'image': 'assets/noodles.png',
      'items': [
        {'name': 'Idly', 'price': 30},
        {'name': 'Plain Dosa', 'price': 30},
        {'name': 'Kal Dosa', 'price': 30},
        {'name': 'Ghee Roast', 'price': 35},
        {'name': 'Podi Dosa', 'price': 35},
        {'name': 'Egg Dosa', 'price': 35},
        {'name': 'Masala Dosa', 'price': 35},
        {'name': 'Onion Uthappam', 'price': 40},
        {'name': 'Vadai', 'price': 10},
        {'name': 'Masala Vadai', 'price': 10},
        {'name': 'Pongal', 'price': 25},
        {'name': 'Poori', 'price': 30},
        {'name': 'Filter Coffee', 'price': 15},
        {'name': 'Ginger Tea', 'price': 10},
      ],
    },
    {
      'name': 'Fresh Juice',
      'image': 'assets/sodas.png',
      'items': [
        {'name': 'Sweet Lime Juice', 'price': 30},
        {'name': 'Grapes Juice', 'price': 30},
        {'name': 'Lemon Juice', 'price': 20},
        {'name': 'Pine Apple Juice', 'price': 40},
        {'name': 'Water Melon Juice', 'price': 30},
        {'name': 'Pomegranate Juice', 'price': 40},
        {'name': 'ABC Juice', 'price': 40},
        {'name': 'Fruit Salad', 'price': 35},
        {'name': 'Vegetable Salad', 'price': 25},
        {'name': 'Amla Juice', 'price': 20},
        {'name': 'Papaya Juice', 'price': 40},
        {'name': 'Musk Melon Juice', 'price': 30},
        {'name': 'Apple Milk Shake', 'price': 50},
        {'name': 'Orange Juice', 'price': 40},
        {'name': 'Fruits Custard', 'price': 50},
        {'name': 'Nannari Sarpath', 'price': 20},
        {'name': 'Rose Milk', 'price': 30},
        {'name': 'Badam Milk', 'price': 30},
        {'name': 'Butter Milk', 'price': 10},
        {'name': 'Lomon Soda', 'price': 20},
        {'name': 'Pine Apple Cut', 'price': 20},
        {'name': 'Mango Cut', 'price': 15},
      ],
    },
    {
      'name': 'Ready Made Juice',
      'image': 'assets/sodas.png',
      'items': [
        {'name': 'Chocolate Milk', 'price': 60},
        {'name': 'Cold Coffee', 'price': 60},
        {'name': 'Basil Lemonade', 'price': 40},
        {'name': 'Blueberry Smooth', 'price': 60},
        {'name': 'Yogurt', 'price': 50},
        {'name': 'Hatsun-Orange', 'price': 10},
        {'name': 'Hatsun-Mongo', 'price': 10},
        {'name': 'Strawberry Yoghurt', 'price': 25},
        {'name': 'Blueberry Yoghurt', 'price': 25},
        {'name': 'Maa Juice', 'price': 10},
        {'name': 'Cavins Milkshake', 'price': 40},
        {'name': 'Coca Cola', 'price': 20},
        {'name': 'Sprite', 'price': 20},
        {'name': 'Tropicana', 'price': 20},
        {'name': 'Thums Up', 'price': 20},
        {'name': 'Pulpy Orange', 'price': 25},
        {'name': 'Bovonta', 'price': 30},
        {'name': 'Tin', 'price': 40},
        {'name': 'Water Bottle', 'price': 10},
        {'name': 'Frooti', 'price': 20},
        {'name': 'N. Chilled Latte', 'price': 45},
        {'name': 'N. Choco Mocha', 'price': 45},
        {'name': 'N. Intense Cafe', 'price': 45},
      ],
    },
    {
      'name': 'Chocolate',
      'image': 'assets/dessert.png',
      'items': [
        {'name': 'Bar One', 'price': 10},
        {'name': 'Milky Bar', 'price': 10},
        {'name': 'Nestle Classic', 'price': 10},
        {'name': 'Kitkat', 'price': 10},
        {'name': 'Munch', 'price': 10},
        {'name': 'Munch-5', 'price': 5},
        {'name': 'Milky Bar-20', 'price': 20},
        {'name': 'Munch-20', 'price': 20},
        {'name': 'Nestle Classic-20', 'price': 20},
        {'name': 'Kitkat-20', 'price': 20},
        {'name': 'Kitkat-35', 'price': 35},
        {'name': 'Munch-30', 'price': 30},
        {'name': 'Kitkat-55', 'price': 55},
        {'name': 'Polo', 'price': 5},
      ],
    },
    {
      'name': 'Ice Cream',
      'image': 'assets/dessert.png',
      'items': [
        {'name': 'Cone (Butter, Venila)', 'price': 40},
        {'name': 'Mango Stick', 'price': 30},
        {'name': 'Vennila Cup', 'price': 10},
        {'name': 'Berry Lime Stick', 'price': 15},
        {'name': 'Pista Stick Ice', 'price': 20},
        {'name': 'Cone Ice', 'price': 50},
        {'name': 'Sipup', 'price': 10},
        {'name': 'Pine Apple Stick Ice', 'price': 10},
        {'name': 'Dilse Butter/Choco', 'price': 30},
        {'name': 'Dilse Redvel/Vennila', 'price': 40},
        {'name': 'Chocobar', 'price': 30},
        {'name': 'Cone Ice Rs20', 'price': 20},
        {'name': 'Ball Ice', 'price': 20},
        {'name': 'Arun Ice-10', 'price': 10},
        {'name': 'Arun Ice-15', 'price': 15},
        {'name': 'Arun Ice-20', 'price': 20},
        {'name': 'Arun Ice-25', 'price': 25},
        {'name': 'Arun Ice-30', 'price': 30},
        {'name': 'Arun Ice-40', 'price': 40},
        {'name': 'Arun Ice-50', 'price': 50},
        {'name': 'Arun Ice-60', 'price': 60},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedTab == 0) {
      // Home tab: horizontal categories, vertical food list
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25, // 1/4 of the screen height
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/ritcanteenphoto.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // In the build method, replace the category selector and food list with a grid/list of menuCategories.
            // On tap of a category, navigate to a new page showing the items for that category.
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: menuCategories.length,
                itemBuilder: (context, index) {
                  final category = menuCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailPage(category: category),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              category['image'],
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (_selectedTab == 1) {
      // Cart tab
      body = CartPage(cartItems: cartItems);
    } else if (_selectedTab == 2) {
      body = GeminiChatPage();
    } else {
      // Profile tab with editable fields and modern UI
      final user = FirebaseAuth.instance.currentUser;
      final TextEditingController nameController = TextEditingController(text: user?.displayName ?? '');
      final TextEditingController emailController = TextEditingController(text: user?.email ?? '');
      final TextEditingController regNoController = TextEditingController(text: ''); // Load from Firestore if needed
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                  child: profileImageUrl == null ? Icon(Icons.person, size: 60, color: Colors.deepPurple) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _uploadingImage ? null : _pickAndUploadProfileImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: _uploadingImage
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.camera_alt, color: Colors.deepPurple, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: regNoController,
              enabled: user?.isAnonymous ?? false,
              decoration: InputDecoration(
                labelText: 'Register Number',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () async {
                // Save logic: update Firestore or FirebaseAuth profile
                // ...implement save logic here...
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated!')),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.lock_outline),
              label: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final oldPasswordController = TextEditingController();
                    final newPasswordController = TextEditingController();
                    final confirmPasswordController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Change Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: oldPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Old Password'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'New Password'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Confirm New Password'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (newPasswordController.text != confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null && oldPasswordController.text.isNotEmpty) {
                                // Re-authenticate user
                                final cred = EmailAuthProvider.credential(
                                  email: user.email ?? '',
                                  password: oldPasswordController.text,
                                );
                                await user.reauthenticateWithCredential(cred);
                                await user.updatePassword(newPasswordController.text);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password changed successfully!')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully!')),
                );
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchOrderHistory(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Text('No order history yet.', style: TextStyle(color: Colors.grey));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...orders.map((order) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('Order #${order['orderId'] ?? ''}'),
                        subtitle: Text('Total: ₹${order['total'] ?? ''}\n${order['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(order['timestamp'].millisecondsSinceEpoch).toLocal().toString() : ''}'),
                        trailing: Icon(Icons.receipt_long, color: Colors.deepPurple),
                      ),
                    )),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: FoodSearchDelegate(menuCategories), // Search all items
              );
              if (result != null) {
                setState(() => searchQuery = result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: body,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => _selectedTab = index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => GeminiChatPage()));
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchOrderHistory(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}

class FoodCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  const FoodCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ListTile(
          leading: Semantics(
            label: item['name'] + ' image',
            child: Image.asset(item['image'], width: 48, height: 48),
          ),
          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(item['rating'].toString()),
                ],
              ),
              Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
          trailing: Semantics(
            label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            button: true,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.deepPurple,
              ),
              onPressed: onFavoriteToggle,
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final List<String> categoryImages;
  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;
  const CategorySelector({
    super.key,
    required this.categories,
    required this.categoryImages,
    required this.selectedCategory,
    required this.onCategorySelected,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;
          return Material(
            color: isSelected ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onCategorySelected(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: '${categories[index]} category',
                      child: Image.asset(categoryImages[index], height: 32, width: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> menuCategories;
  double? minPrice;
  double? maxPrice;
  double? minRating;
  String? selectedCategory;
  FoodSearchDelegate(this.menuCategories);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) {
                final categories = menuCategories.map((e) => e['name'] as String).toList();
                String? tempCategory = selectedCategory;
                double? tempMinPrice = minPrice;
                double? tempMaxPrice = maxPrice;
                double? tempMinRating = minRating;
                return AlertDialog(
                  title: const Text('Filter'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: tempCategory,
                          hint: const Text('Category'),
                          items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (v) => tempCategory = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Min Price'),
                          keyboardType: TextInputType.number,
                          initialValue: tempMinPrice?.toString(),
                          onChanged: (v) => tempMinPrice = double.tryParse(v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Max Price'),
                          keyboardType: TextInputType.number,
                          initialValue: tempMaxPrice?.toString(),
                          onChanged: (v) => tempMaxPrice = double.tryParse(v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Min Rating'),
                          keyboardType: TextInputType.number,
                          initialValue: tempMinRating?.toString(),
                          onChanged: (v) => tempMinRating = double.tryParse(v),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        selectedCategory = tempCategory;
                        minPrice = tempMinPrice;
                        maxPrice = tempMaxPrice;
                        minRating = tempMinRating;
                        Navigator.pop(context);
                        showSuggestions(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    var results = menuCategories.expand((cat) => (cat['items'] as List<dynamic>).map((item) => {...item, 'category': cat['name'], 'image': cat['image']})).toList();
    if (query.isNotEmpty) {
      results = results.where((item) =>
        item['name'].toLowerCase().contains(query.toLowerCase()) ||
        (item['description']?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
    if (selectedCategory != null) {
      results = results.where((item) => item['category'] == selectedCategory).toList();
    }
    if (minPrice != null) {
      results = results.where((item) => (item['price'] as num) >= minPrice!).toList();
    }
    if (maxPrice != null) {
      results = results.where((item) => (item['price'] as num) <= maxPrice!).toList();
    }
    if (minRating != null) {
      results = results.where((item) => (item['rating'] ?? 0) >= minRating!).toList();
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Image.asset(item['image'], width: 40, height: 40),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('₹${item['price']}'),
            trailing: item['rating'] != null ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(item['rating'].toString()),
              ],
            ) : null,
            onTap: () => close(context, item['name']),
          ),
        );
      },
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String? userId;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _showPreview(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item['image'] ?? widget.category['image'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 6),
              Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              if (item['description'] != null)
                Text(item['description'], style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    cartItems.add(item);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['name']} added to cart!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> item) async {
    double userRating = 0;
    String userReview = '';
    final docId = '${item['name']}_${userId ?? ''}';
    final docRef = FirebaseFirestore.instance.collection('reviews').doc(docId);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      final data = docSnap.data() as Map<String, dynamic>;
      userRating = (data['rating'] ?? 0).toDouble();
      userReview = data['review'] ?? '';
    }
    showDialog(
      context: context,
      builder: (context) {
        double tempRating = userRating;
        TextEditingController reviewController = TextEditingController(text: userReview);
        return AlertDialog(
          title: Text('Review ${item['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < tempRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      tempRating = index + 1.0;
                    });
                    Navigator.of(context).pop();
                    _showReviewDialog(item);
                  },
                )),
              ),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(labelText: 'Write your review'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await docRef.set({
                  'item': item['name'],
                  'rating': tempRating,
                  'review': reviewController.text,
                  'userId': userId,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.category['items'] as List<dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text(widget.category['name'])),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + index * 50),
            curve: Curves.easeIn,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: GestureDetector(
                      onTap: () => _showPreview(item),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['image'] ?? widget.category['image'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${item['price']}'),
                        if (item['description'] != null) Text(item['description'], style: const TextStyle(fontSize: 12)),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('item', isEqualTo: item['name'])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final docs = (snapshot.data as QuerySnapshot).docs;
                            if (docs.isEmpty) return const Text('No reviews yet');
                            double avg = 0;
                            for (var d in docs) {
                              avg += (d['rating'] ?? 0).toDouble();
                            }
                            avg = avg / docs.length;
                            return Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(avg.toStringAsFixed(1)),
                                Text(' (${docs.length} reviews)', style: const TextStyle(fontSize: 12)),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye, color: Colors.deepPurple),
                          onPressed: () => _showPreview(item),
                          tooltip: 'Preview',
                        ),
                        IconButton(
                          icon: const Icon(Icons.rate_review, color: Colors.deepPurple),
                          onPressed: () => _showReviewDialog(item),
                          tooltip: 'Write/Edit Review',
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.deepPurple),
                          onPressed: () {
                            setState(() {
                              cartItems.add(item);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item['name']} added to cart!')),
                            );
                          },
                          tooltip: 'Add to Cart',
                        ),
                      ],
                    ),
                  ),
                  // Display reviews directly under each item
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('item', isEqualTo: item['name'])
                        .orderBy('timestamp', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final docs = (snapshot.data as QuerySnapshot).docs;
                      if (docs.isEmpty) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recent Reviews:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ...docs.take(3).map((d) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.person, color: Colors.deepPurple),
                                  title: Row(
                                    children: [
                                      ...List.generate(5, (i) => Icon(
                                            i < (d['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          )),
                                      const SizedBox(width: 8),
                                      Text((d['rating'] ?? 0).toString()),
                                    ],
                                  ),
                                  subtitle: Text(d['review'] ?? '', style: const TextStyle(fontSize: 13)),
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final VoidCallback onEdit;
  const ProfileInfoCard({super.key, required this.name, required this.email, required this.phone, required this.bio, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
              const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: onEdit,
                child: const Text('EDIT', style: TextStyle(color: Color(0xFFFFA726), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            backgroundImage: null, // Add image logic if needed
            child: Icon(Icons.person, size: 54, color: Colors.deepPurple.shade200),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(bio, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.person_outline, 'FULL NAME', name),
                const SizedBox(height: 12),
                _infoRow(Icons.email_outlined, 'EMAIL', email),
                const SizedBox(height: 12),
                _infoRow(Icons.phone_outlined, 'PHONE NUMBER', phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}

class EditProfilePage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final VoidCallback onSave;
  const EditProfilePage({super.key, required this.nameController, required this.emailController, required this.phoneController, required this.bioController, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage: null, // Add image logic if needed
                  child: Icon(Icons.person, size: 54, color: Colors.deepPurple.shade200),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFFA726),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _editField('FULL NAME', nameController),
            const SizedBox(height: 12),
            _editField('EMAIL', emailController),
            const SizedBox(height: 12),
            _editField('PHONE NUMBER', phoneController),
            const SizedBox(height: 12),
            _editField('BIO', bioController, maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: onSave,
                child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

void showAppSnackBar(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<void> showAppDialog(BuildContext context, String title, String content) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
