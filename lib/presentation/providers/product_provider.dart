import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

// Product list provider
final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductNotifier(ref);
});

// Featured products provider
final featuredProductsProvider = StateNotifierProvider<FeaturedProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return FeaturedProductsNotifier(ref);
});

// Product search provider
final productSearchProvider = StateNotifierProvider.family<ProductSearchNotifier, AsyncValue<List<Product>>, String>((ref, query) {
  return ProductSearchNotifier(ref, query);
});

// Product by category provider
final productsByCategoryProvider = StateNotifierProvider.family<ProductsByCategoryNotifier, AsyncValue<List<Product>>, String>((ref, categoryId) {
  return ProductsByCategoryNotifier(ref, categoryId);
});

// Single product provider
final singleProductProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProductById(productId);
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  final Ref ref;
  late final ProductRepository _repository;

  void _init() {
    _repository = ref.read(productRepositoryProvider);
  }

  Future<void> loadProducts({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    if (page == 1) {
      state = const AsyncValue.loading();
    }
    
    try {
      _init();
      final products = await _repository.getProducts(
        page: page,
        limit: limit,
        sortBy: sortBy,
        ascending: ascending,
      );
      
      if (page == 1) {
        state = AsyncValue.data(products);
      } else {
        // Append to existing list for pagination
        state = state.when(
          data: (existingProducts) => AsyncValue.data([...existingProducts, ...products]),
          loading: () => AsyncValue.data(products),
          error: (error, stack) => AsyncValue.data(products),
        );
      }
    } catch (error, stack) {
      if (page == 1) {
        state = AsyncValue.error(error, stack);
      }
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }

  Future<void> loadMore() async {
    final currentProducts = state.value ?? [];
    final currentPage = (currentProducts.length / 20).ceil() + 1;
    await loadProducts(page: currentPage);
  }
}

class FeaturedProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FeaturedProductsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadFeaturedProducts();
  }

  final Ref ref;

  Future<void> loadFeaturedProducts() async {
    try {
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getFeaturedProducts();
      state = AsyncValue.data(products);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

class ProductSearchNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductSearchNotifier(this.ref, this.query) : super(const AsyncValue.loading()) {
    search();
  }

  final Ref ref;
  final String query;

  Future<void> search({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  }) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.searchProducts(
        query: query,
        filters: filters,
        sortBy: sortBy,
        ascending: ascending,
      );
      state = AsyncValue.data(products);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

class ProductsByCategoryNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductsByCategoryNotifier(this.ref, this.categoryId) : super(const AsyncValue.loading()) {
    loadProductsByCategory();
  }

  final Ref ref;
  final String categoryId;

  Future<void> loadProductsByCategory({
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool ascending = true,
  }) async {
    if (page == 1) {
      state = const AsyncValue.loading();
    }
    
    try {
      final repository = ref.read(productRepositoryProvider);
      final products = await repository.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        sortBy: sortBy,
        ascending: ascending,
      );
      
      if (page == 1) {
        state = AsyncValue.data(products);
      } else {
        state = state.when(
          data: (existingProducts) => AsyncValue.data([...existingProducts, ...products]),
          loading: () => AsyncValue.data(products),
          error: (error, stack) => AsyncValue.data(products),
        );
      }
    } catch (error, stack) {
      if (page == 1) {
        state = AsyncValue.error(error, stack);
      }
    }
  }
}