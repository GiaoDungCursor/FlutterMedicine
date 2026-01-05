import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order.dart' show MedicineOrder;
import '../../widgets/loading_indicator.dart';

class PendingOrdersScreen extends StatelessWidget {
  const PendingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
      ),
      body: StreamBuilder<List<MedicineOrder>>(
        stream: orderService.getPendingOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading pending orders...');
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
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pending orders',
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
              return _buildOrderCard(
                context,
                order,
                currencyFormat,
                dateFormat,
                orderService,
              );
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
    OrderService orderService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: const Icon(Icons.pending_actions, color: Colors.orange),
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
            Text('Items: ${order.items.length}'),
          ],
        ),
        trailing: Chip(
          label: const Text(
            'PENDING',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                const Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.medicineName} x${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.subtotal),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                const SizedBox(height: 8),
                // Shipping Information
                const Text(
                  'Shipping Information:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Name', order.shippingInfo.fullName),
                _buildInfoRow('Phone', order.shippingInfo.phone),
                _buildInfoRow('Address', order.shippingInfo.address),
                if (order.shippingInfo.notes != null &&
                    order.shippingInfo.notes!.isNotEmpty)
                  _buildInfoRow('Notes', order.shippingInfo.notes!),
                const Divider(),
                const SizedBox(height: 8),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateOrderStatus(
                          context,
                          order,
                          'cancelled',
                          orderService,
                        ),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(
                          context,
                          order,
                          'processing',
                          orderService,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    MedicineOrder order,
    String newStatus,
    OrderService orderService,
  ) async {
    final statusText = newStatus == 'processing' ? 'approve' : 'reject';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${statusText[0].toUpperCase()}${statusText.substring(1)} Order'),
        content: Text(
          'Are you sure you want to $statusText order #${order.id?.substring(0, 8) ?? 'N/A'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'processing' ? Colors.green : Colors.red,
            ),
            child: Text(statusText[0].toUpperCase() + statusText.substring(1)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await orderService.updateOrderStatus(order.id!, newStatus);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order ${newStatus == 'processing' ? 'approved' : 'rejected'} successfully',
              ),
              backgroundColor: newStatus == 'processing' ? Colors.green : Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update order: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

