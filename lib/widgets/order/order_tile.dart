import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String orderId;
  final String status;
  final String date;

  const OrderTile({
    super.key,
    required this.orderId,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt),
      title: Text('Order #$orderId'),
      subtitle: Text('Status: $status\nDate: $date'),
    );
  }
}
