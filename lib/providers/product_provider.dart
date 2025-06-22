import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  Future<void> fetchProducts() async {
    // TODO: Fetch products from Supabase
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    // TODO: Add product to Supabase
    notifyListeners();
  }

  Future<void> updateProduct(ProductModel product) async {
    // TODO: Update product in Supabase
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    // TODO: Delete product from Supabase
    notifyListeners();
  }
}
