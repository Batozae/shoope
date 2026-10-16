import 'package:flutter/material.dart';

// Placeholder halaman Keranjang Saya
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
      ),
      body: const Center(
        child: Text(
          'Keranjang Saya',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

