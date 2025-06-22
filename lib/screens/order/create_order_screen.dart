import 'package:flutter/material.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Create order logic
          },
          child: const Text('Create Order'),
        ),
      ),
    );
  }
}
