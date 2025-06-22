import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl();
});

abstract class ProductRemoteDataSource {
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

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      
      var query = _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('is_active', true)
          .range(from, to);

      if (sortBy != null) {
        query = query.order(sortBy, ascending: ascending);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query;
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);

      return response.map((json) => Product.fromJson(json)).toList();
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
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      
      var query = _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .range(from, to);

      if (sortBy != null) {
        query = query.order(sortBy, ascending: ascending);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query;
      return response.map((json) => Product.fromJson(json)).toList();
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
      var supabaseQuery = _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('is_active', true)
          .ilike('name', '%$query%');

      // Apply filters
      if (filters != null) {
        if (filters['category_id'] != null) {
          supabaseQuery = supabaseQuery.eq('category_id', filters['category_id']);
        }
        if (filters['min_price'] != null) {
          supabaseQuery = supabaseQuery.gte('price', filters['min_price']);
        }
        if (filters['max_price'] != null) {
          supabaseQuery = supabaseQuery.lte('price', filters['max_price']);
        }
        if (filters['condition'] != null) {
          supabaseQuery = supabaseQuery.eq('condition', filters['condition']);
        }
      }

      if (sortBy != null) {
        supabaseQuery = supabaseQuery.order(sortBy, ascending: ascending);
      } else {
        supabaseQuery = supabaseQuery.order('created_at', ascending: false);
      }

      final response = await supabaseQuery.limit(50);
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('id', productId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      
      // Increment view count
      await _supabase
          .from('products')
          .update({'view_count': (response['view_count'] ?? 0) + 1})
          .eq('id', productId);

      return Product.fromJson(response);
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
      var query = _supabase
          .from('products')
          .select('''
            *,
            categories(*),
            profiles(*)
          ''')
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .order('view_count', ascending: false)
          .limit(limit);

      if (excludeProductId != null) {
        query = query.neq('id', excludeProductId);
      }

      final response = await query;
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch related products: $e');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .update({'is_active': false})
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}