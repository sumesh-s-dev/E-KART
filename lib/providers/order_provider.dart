import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  Future<void> fetchOrders() async {
    // TODO: Fetch orders from Supabase
    notifyListeners();
  }

  Future<void> createOrder(OrderModel order) async {
    // TODO: Create order in Supabase
    notifyListeners();
  }

  Future<void> updateOrder(OrderModel order) async {
    // TODO: Update order in Supabase
    notifyListeners();
  }
}
