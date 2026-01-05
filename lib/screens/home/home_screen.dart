import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine.dart';
import '../../models/user_model.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../admin/admin_panel_screen.dart';
import '../cart/cart_screen.dart';
import '../cart/order_history_screen.dart';
import '../../services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Store'),
        actions: [
          // Order History Icon
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
            tooltip: 'Order History',
          ),
          // Cart Icon with badge
          Consumer<CartService>(
            builder: (context, cartService, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                    tooltip: 'Shopping Cart',
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip('All'),
                      ...AppConstants.medicineCategories
                          .map((category) => _buildCategoryChip(category)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Admin Panel Button
          StreamBuilder<User?>(
            stream: Provider.of<AuthService>(context, listen: false).authStateChanges,
            builder: (context, authSnapshot) {
              if (authSnapshot.hasData) {
                return FutureBuilder<bool>(
                  future: Provider.of<AuthService>(context, listen: false)
                      .isAdmin(authSnapshot.data!.uid),
                  builder: (context, adminSnapshot) {
                    if (adminSnapshot.hasData && adminSnapshot.data == true) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminPanelScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Admin Panel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 8),
          // Medicines List
          Expanded(
            child: Consumer<MedicineService>(
              builder: (context, medicineService, _) {
                return StreamBuilder<List<Medicine>>(
                  stream: _selectedCategory == 'All'
                      ? medicineService.getAllMedicines()
                      : medicineService.getMedicinesByCategory(_selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator(message: 'Loading medicines...');
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No medicines found'),
                      );
                    }

                    // Filter by search query
                    List<Medicine> filteredMedicines = snapshot.data!
                        .where((medicine) => medicine.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                    if (filteredMedicines.isEmpty) {
                      return const Center(
                        child: Text('No medicines match your search'),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredMedicines.length,
                      itemBuilder: (context, index) {
                        return MedicineCard(
                          medicine: filteredMedicines[index],
                          onTap: () {
                            // Show medicine details dialog
                            _showMedicineDetails(context, filteredMedicines[index]);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
        selectedColor: Colors.blue.shade200,
        checkmarkColor: Colors.blue.shade800,
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicine.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Manufacturer: ${medicine.manufacturer}'),
              const SizedBox(height: 8),
              Text('Category: ${medicine.category}'),
              const SizedBox(height: 8),
              Text('Price: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(medicine.price)}'),
              const SizedBox(height: 8),
              Text('Stock: ${medicine.stock}'),
              const SizedBox(height: 8),
              Text('Description: ${medicine.description}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

