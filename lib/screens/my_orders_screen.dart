import 'package:flutter/material.dart';
import 'package:fasalmitra/widgets/orders/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const String routeName = '/my-orders';

  @override
  Widget build(BuildContext context) {
    // Dummy Data matching the image
    final orders = [
      {
        'id': '6',
        'product': 'soymeal',
        'amount': '₹150',
        'status': 'DEPOSITED',
        'date': '12/3/2025',
      },
      {
        'id': '3',
        'product': 'sunflower',
        'amount': '₹12000',
        'status': 'DEPOSITED',
        'date': '12/2/2025',
      },
      {
        'id': '7',
        'product': 'Groundnut Seeds',
        'amount': '₹3000',
        'status': 'PENDING',
        'date': '12/4/2025',
      },
    ];

    return Scaffold(
      backgroundColor:
          Colors.grey.shade50, // Light background to make white cards pop
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            orderId: order['id']!,
            productName: order['product']!,
            amount: order['amount']!,
            status: order['status']!,
            date: order['date']!,
            onReceived: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order['id']} marked as Received'),
                ),
              );
            },
            onNotReceived: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reported issue for Order #${order['id']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
