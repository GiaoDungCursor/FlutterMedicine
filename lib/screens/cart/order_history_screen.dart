import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order.dart' show MedicineOrder;
import '../../widgets/loading_indicator.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final orderService = Provider.of<OrderService>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view orders'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<List<MedicineOrder>>(
        stream: orderService.getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading orders...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return _buildOrderCard(context, order, currencyFormat, dateFormat);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    MedicineOrder order,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.refresh;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${dateFormat.format(order.createdAt)}'),
            Text(
              'Total: ${currencyFormat.format(order.totalAmount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            order.status.toUpperCase(),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: statusColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.medicineName} x${item.quantity}'),
                          Text(currencyFormat.format(item.subtotal)),
                        ],
                      ),
                    )),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Shipping Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Name: ${order.shippingInfo.fullName}'),
                Text('Phone: ${order.shippingInfo.phone}'),
                Text('Address: ${order.shippingInfo.address}'),
                if (order.shippingInfo.notes != null &&
                    order.shippingInfo.notes!.isNotEmpty)
                  Text('Notes: ${order.shippingInfo.notes}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

