import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String productName;
  final String amount;
  final String status;
  final String date;
  final VoidCallback? onReceived;
  final VoidCallback? onNotReceived;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.productName,
    required this.amount,
    required this.status,
    required this.date,
    this.onReceived,
    this.onNotReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Adding a subtle border if needed, or keeping it clean
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #$orderId',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Product', productName),
            const SizedBox(height: 8),
            _buildInfoRow('Amount', amount),
            const SizedBox(height: 8),
            _buildInfoRow('Status', status, isStatus: true),
            const SizedBox(height: 8),
            _buildInfoRow('Date', date),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildButton(
                  context,
                  label: 'Received Goods',
                  color: Colors.green, // Adjust to match image green
                  onTap: onReceived,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  context,
                  label: 'Not Received',
                  color: Colors.red, // Adjust to match image red
                  onTap: onNotReceived,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
