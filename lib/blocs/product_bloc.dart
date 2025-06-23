import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class FilterProducts extends ProductEvent {
  final String category;
  final String searchQuery;

  const FilterProducts({
    this.category = '',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [category, searchQuery];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String? category;
  final String? searchQuery;

  const ProductLoaded(
    this.products, {
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, category, searchQuery];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final SupabaseClient _supabaseClient;
  List<Product> _allProducts = [];

  ProductBloc({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<FilterProducts>(_onFilterProducts);

    // Set up real-time subscription
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    try {
      _supabaseClient
          .from('products')
          .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
        _allProducts = data.map((json) => Product.fromJson(json)).toList();
        add(const FilterProducts());
      });
    } catch (e) {
      print('Error setting up real-time subscription: $e');
    }
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      final response = await _supabaseClient
          .from('products')
          .select()
          .order('created_at', ascending: false);

      _allProducts = response.map((json) => Product.fromJson(json)).toList();
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      print('Error loading products: $e');
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      final productData = event.product.toJson();
      productData['id'] = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabaseClient.from('products').insert(productData);

      // The real-time subscription will handle the state update
    } catch (e) {
      print('Error adding product: $e');
      emit(ProductError('Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      final productData = event.product.toJson();
      productData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseClient
          .from('products')
          .update(productData)
          .eq('product_id', event.product.productId);

      // The real-time subscription will handle the state update
    } catch (e) {
      print('Error updating product: $e');
      emit(ProductError('Failed to update product: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      await _supabaseClient
          .from('products')
          .delete()
          .eq('product_id', event.productId);

      // The real-time subscription will handle the state update
    } catch (e) {
      print('Error deleting product: $e');
      emit(ProductError('Failed to delete product: ${e.toString()}'));
    }
  }

  void _onFilterProducts(
    FilterProducts event,
    Emitter<ProductState> emit,
  ) {
    try {
      List<Product> filteredProducts = _allProducts;

      // Filter by category
      if (event.category.isNotEmpty) {
        filteredProducts = filteredProducts
            .where((product) =>
                product.category != null &&
                event.category != null &&
                product.category!.toLowerCase() ==
                    event.category!.toLowerCase())
            .toList();
      }

      // Filter by search query
      if (event.searchQuery.isNotEmpty) {
        filteredProducts = filteredProducts
            .where((product) =>
                (product.name != null &&
                    product.name!
                        .toLowerCase()
                        .contains(event.searchQuery.toLowerCase())) ||
                (product.description != null &&
                    product.description!
                        .toLowerCase()
                        .contains(event.searchQuery.toLowerCase())))
            .toList();
      }

      emit(ProductLoaded(
        filteredProducts,
        category: event.category,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      print('Error filtering products: $e');
      emit(ProductError('Failed to filter products: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    // Clean up real-time subscription if needed
    return super.close();
  }
}
