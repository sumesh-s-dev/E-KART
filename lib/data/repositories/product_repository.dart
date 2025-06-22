import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../datasources/remote/product_remote_datasource.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.read(productRemoteDataSourceProvider),
  );
});

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  });
  
  Future<List<Product>> getFeaturedProducts();
  
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  });
  
  Future<List<Product>> searchProducts({
    required String query,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  });
  
  Future<Product?> getProductById(String productId);
  
  Future<List<Product>> getRelatedProducts({
    required String categoryId,
    String? excludeProductId,
    int limit = 6,
  });
  
  Future<Product> createProduct(Product product);
  
  Future<Product> updateProduct(Product product);
  
  Future<void> deleteProduct(String productId);
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      return await remoteDataSource.getProducts(
        page: page,
        limit: limit,
        sortBy: sortBy,
        ascending: ascending,
      );
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      return await remoteDataSource.getFeaturedProducts();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      return await remoteDataSource.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        sortBy: sortBy,
        ascending: ascending,
      );
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts({
    required String query,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      return await remoteDataSource.searchProducts(
        query: query,
        filters: filters,
        sortBy: sortBy,
        ascending: ascending,
      );
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      return await remoteDataSource.getProductById(productId);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<List<Product>> getRelatedProducts({
    required String categoryId,
    String? excludeProductId,
    int limit = 6,
  }) async {
    try {
      return await remoteDataSource.getRelatedProducts(
        categoryId: categoryId,
        excludeProductId: excludeProductId,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch related products: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      return await remoteDataSource.createProduct(product);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      return await remoteDataSource.updateProduct(product);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}