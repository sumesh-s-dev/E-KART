import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'auth_provider.dart';

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((ref) {
  return CartNotifier(ref);
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).when(
    data: (cart) => cart.totalItems,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).when(
    data: (cart) => cart.subtotal,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  CartNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  late final CartRepository _repository;

  void _init() {
    _repository = ref.read(cartRepositoryProvider);
    _loadCart();
    
    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        _loadCart();
      } else if (!next.isAuthenticated && previous?.isAuthenticated == true) {
        state = const AsyncValue.data(Cart(userId: '', items: []));
      }
    });
  }

  Future<void> _loadCart() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = const AsyncValue.data(Cart(userId: '', items: []));
      return;
    }

    try {
      final cart = await _repository.getCart();
      state = AsyncValue.data(cart);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      await _repository.addToCart(product.id, quantity);
      await _loadCart();
    } catch (error) {
      // Handle error but don't update state to prevent UI flicker
      rethrow;
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      await _repository.updateCartItemQuantity(cartItemId, quantity);
      await _loadCart();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _repository.removeFromCart(cartItemId);
      await _loadCart();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      await _loadCart();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refreshCart() async {
    await _loadCart();
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return state.when(
      data: (cart) => cart.items.any((item) => item.productId == productId),
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Get quantity of product in cart
  int getProductQuantityInCart(String productId) {
    return state.when(
      data: (cart) {
        final item = cart.items.firstWhere(
          (item) => item.productId == productId,
          orElse: () => const CartItem(
            id: '',
            userId: '',
            productId: '',
            quantity: 0,
          ),
        );
        return item.quantity;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  }
}