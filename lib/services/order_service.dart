import 'package:fasalmitra/services/api.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/cart_service.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  Future<void> createOrder(List<CartItem> items, double totalAmount) async {
    final token = AuthService.instance.token;
    if (token == null) {
      throw Exception('User must be logged in to place an order');
    }

    // API supports buying one product at a time via /buy/
    // We will loop through items and buy them.
    // Note: Transaction consistency? If one fails?
    // For now, we attempt all.
    List<String> errors = [];

    for (var item in items) {
      try {
        await ApiService.instance.post(
          '/buy/',
          token: token,
          body: {'product_id': int.tryParse(item.listing.id) ?? 0},
        );
      } catch (e) {
        errors.add('Failed to buy ${item.listing.title}: $e');
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(errors.join('\n'));
    }
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final token = AuthService.instance.token;
    if (token == null) return [];

    try {
      final response = await ApiService.instance.get('/orders/', token: token);

      if (response['success'] != null) {
        final list = response['success']['body'] as List;
        return list.map((item) {
          return {
            'id': item['id'].toString(),
            'product': item['product_name'] ?? 'Unknown',
            'amount': '₹${item['amount']}',
            'status': item['status'],
            'date': item['date'], // Formatted?
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<void> confirmReceipt(String orderId) async {
    final token = AuthService.instance.token;
    if (token == null) return;

    await ApiService.instance.post(
      '/confirm/',
      token: token,
      body: {'order_id': int.tryParse(orderId) ?? 0},
    );
  }

  Future<void> requestRefund(String orderId) async {
    final token = AuthService.instance.token;
    if (token == null) return;

    await ApiService.instance.post(
      '/refund/',
      token: token,
      body: {'order_id': int.tryParse(orderId) ?? 0},
    );
  }

  // Deprecated / Unused in new flow?
  Future<List<Map<String, dynamic>>> getOrdersForFarmer(String farmerId) async {
    return [];
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // mapped to confirm/refund? Use specific methods instead.
    if (newStatus == 'COMPLETED') {
      await confirmReceipt(orderId);
    } else if (newStatus == 'REFUNDED') {
      await requestRefund(orderId);
    }
  }
}
