import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/cart/cart_summary.dart';
import 'empty_cart_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCart();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _loadCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).refreshCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: cartState.when(
          data: (cart) => cart.isEmpty 
              ? const EmptyCartScreen()
              : _buildCartContent(cart),
          loading: () => const LoadingWidget(),
          error: (error, stack) => _buildErrorWidget(error.toString()),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final cartItemCount = ref.watch(cartItemCountProvider);
    
    return AppBar(
      title: Text(
        'Shopping Cart ($cartItemCount)',
        style: const TextStyle(color: AppColors.primaryGold),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        if (cartItemCount > 0)
          TextButton(
            onPressed: _showClearCartDialog,
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
      ],
    );
  }

  Widget _buildCartContent(Cart cart) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Cart Items List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(cartProvider.notifier).refreshCart();
              },
              color: AppColors.primaryGold,
              backgroundColor: AppColors.cardBlue,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 600),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: CartItemCard(
                          cartItem: cart.items[index],
                          onQuantityChanged: (newQuantity) {
                            _updateQuantity(cart.items[index].id, newQuantity);
                          },
                          onRemove: () {
                            _removeItem(cart.items[index]);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Cart Summary and Checkout
          _buildBottomSection(cart),
        ],
      ),
    );
  }

  Widget _buildBottomSection(Cart cart) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBlue,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart Summary
            CartSummary(cart: cart),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Checkout Button
            GradientButton(
              text: 'Proceed to Checkout',
              onPressed: () => context.go('/cart/checkout'),
              gradient: AppTheme.primaryGradient,
              icon: const Icon(
                Icons.shopping_cart_checkout,
                size: 20,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingSmall),
            
            // Continue Shopping
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load cart',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).refreshCart();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(String cartItemId, int newQuantity) async {
    try {
      await ref.read(cartProvider.notifier).updateQuantity(
        cartItemId,
        newQuantity,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update quantity');
    }
  }

  void _removeItem(CartItem cartItem) async {
    try {
      await ref.read(cartProvider.notifier).removeFromCart(cartItem.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.product?.name} removed from cart'),
            backgroundColor: AppColors.accentGreen,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // Re-add the item
                if (cartItem.product != null) {
                  ref.read(cartProvider.notifier).addToCart(
                    cartItem.product!,
                    quantity: cartItem.quantity,
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to remove item');
    }
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlue,
        title: const Text(
          'Clear Cart',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCart();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCart() async {
    try {
      await ref.read(cartProvider.notifier).clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart cleared'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to clear cart');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}