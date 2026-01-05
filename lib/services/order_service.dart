import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new order
  Future<String> createOrder(order_model.MedicineOrder order) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('orders')
          .add(order.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  Stream<List<order_model.MedicineOrder>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => order_model.MedicineOrder.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort by createdAt descending on client side to avoid composite index requirement
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Get order by ID
  Future<order_model.MedicineOrder?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        return order_model.MedicineOrder.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Get all pending orders (for admin)
  Stream<List<order_model.MedicineOrder>> getPendingOrders() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => order_model.MedicineOrder.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort by createdAt descending on client side
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}

