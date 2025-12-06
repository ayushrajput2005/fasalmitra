import 'package:flutter/material.dart';
import 'package:fasalmitra/services/order_service.dart';
import 'package:fasalmitra/widgets/orders/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const String routeName = '/my-orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: OrderService.instance.getMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                orderId: order['id']!,
                productName: order['product']!.toString(),
                amount: order['amount']!.toString(),
                status: order['status']!.toString(),
                date: order['date']!.toString(),
                onReceived: () async {
                  try {
                    await OrderService.instance.confirmReceipt(order['id']!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order #${order['id']} Confirmed'),
                      ),
                    );
                    // Ideally refresh UI
                    (context as Element)
                        .markNeedsBuild(); // Hacky force rebuild or use stateful
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                onNotReceived: () async {
                  // Request refund logic? or just report?
                  // Assuming Request Refund is the action here or we map it to refund
                  try {
                    await OrderService.instance.requestRefund(order['id']!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Refund requested for Order #${order['id']}',
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
