import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fasalmitra/services/cart_service.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrder(List<CartItem> items, double totalAmount) async {
    final user = _auth.currentUser;
    if (user == null)
      throw Exception('User must be logged in to place an order');

    // Extract unique seller IDs
    final sellerIds = items
        .map((item) => item.listing.sellerId)
        .where((id) => id != null)
        .toSet()
        .toList();

    final orderData = {
      'buyerId': user.uid,
      'buyerName': user.displayName ?? user.phoneNumber ?? 'Unknown',
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': 'pending',
      'sellerIds': sellerIds,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('orders').add(orderData);
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersForFarmer(String farmerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('sellerIds', arrayContains: farmerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching farmer orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // In a real app, check if the user is authorized (seller or admin)
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
