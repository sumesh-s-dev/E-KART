import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/product/product_image_gallery.dart';
import '../../widgets/product/product_info.dart';
import '../../widgets/product/product_reviews.dart';
import '../../widgets/product/related_products.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PageController _imageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _showAppBar = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupScrollListener();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShowAppBar = _scrollController.offset > 200;
      if (shouldShowAppBar != _showAppBar) {
        setState(() => _showAppBar = shouldShowAppBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(singleProductProvider(widget.productId));
    
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      body: productAsync.when(
        data: (product) => product != null 
            ? _buildProductDetails(product)
            : _buildNotFound(),
        loading: () => const LoadingWidget(),
        error: (error, stack) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    final cartState = ref.watch(cartProvider);
    final isInCart = ref.read(cartProvider.notifier).isProductInCart(product.id);
    final isInWishlist = ref.watch(wishlistProvider.select(
      (wishlist) => wishlist.when(
        data: (items) => items.any((item) => item.id == product.id),
        loading: () => false,
        error: (_, __) => false,
      ),
    ));

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Custom App Bar
        _buildSliverAppBar(product),
        
        // Product Images
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ProductImageGallery(
              images: product.images,
              onImageTap: (index) => _showImageGallery(product.images, index),
            ),
          ),
        ),
        
        // Product Information
        SliverToBoxAdapter(
          child: SlideTransition(
            position: _slideAnimation,
            child: ProductInfo(
              product: product,
              quantity: _quantity,
              onQuantityChanged: (newQuantity) {
                setState(() => _quantity = newQuantity);
              },
            ),
          ),
        ),
        
        // Action Buttons
        SliverToBoxAdapter(
          child: _buildActionButtons(product, isInCart, isInWishlist),
        ),
        
        // Product Reviews
        SliverToBoxAdapter(
          child: ProductReviews(productId: product.id),
        ),
        
        // Related Products
        SliverToBoxAdapter(
          child: RelatedProducts(
            categoryId: product.categoryId,
            excludeProductId: product.id,
          ),
        ),
        
        // Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: _showAppBar 
          ? AppColors.cardBlue.withOpacity(0.95)
          : Colors.transparent,
      elevation: _showAppBar ? 4 : 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBlue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          product.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _toggleWishlist(product),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              ref.watch(wishlistProvider.select(
                (wishlist) => wishlist.when(
                  data: (items) => items.any((item) => item.id == product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  loading: () => Icons.favorite_border,
                  error: (_, __) => Icons.favorite_border,
                ),
              )),
              color: AppColors.errorRed,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _shareProduct(product),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBlue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Product product, bool isInCart, bool isInWishlist) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardBlue,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            // Price and Stock Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      Text(
                        '₹${product.comparePrice!.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: product.isInStock 
                        ? AppColors.accentGreen.withOpacity(0.2)
                        : AppColors.errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(
                      color: product.isInStock 
                          ? AppColors.accentGreen
                          : AppColors.errorRed,
                    ),
                  ),
                  child: Text(
                    product.isInStock 
                        ? 'In Stock (${product.stockQuantity})'
                        : 'Out of Stock',
                    style: TextStyle(
                      color: product.isInStock 
                          ? AppColors.accentGreen
                          : AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                // Add to Wishlist
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleWishlist(product),
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.errorRed,
                    ),
                    label: Text(
                      isInWishlist ? 'Wishlisted' : 'Wishlist',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Add to Cart / Buy Now
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: isInCart ? 'Go to Cart' : 'Add to Cart',
                    onPressed: product.isInStock 
                        ? () => _handleCartAction(product, isInCart)
                        : null,
                    gradient: isInCart 
                        ? const LinearGradient(
                            colors: [AppColors.accentGreen, Color(0xFF2E7D32)],
                          )
                        : AppTheme.primaryGradient,
                    icon: Icon(
                      isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Buy Now Button
            if (product.isInStock)
              GradientButton(
                text: 'Buy Now',
                onPressed: () => _buyNow(product),
                gradient: AppTheme.goldGradient,
                icon: const Icon(
                  Icons.flash_on,
                  size: 20,
                  color: AppColors.deepBlue,
                ),
                textColor: AppColors.deepBlue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Product not found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
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
            'Error loading product',
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
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: PhotoViewGallery.builder(
          itemCount: images.length,
          pageController: PageController(initialPage: initialIndex),
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(images[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _toggleWishlist(Product product) async {
    try {
      await ref.read(wishlistProvider.notifier).toggleWishlist(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(wishlistProvider.notifier).isInWishlist(product.id)
                  ? 'Added to wishlist'
                  : 'Removed from wishlist',
            ),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _handleCartAction(Product product, bool isInCart) async {
    if (isInCart) {
      context.go('/cart');
    } else {
      try {
        await ref.read(cartProvider.notifier).addToCart(
          product,
          quantity: _quantity,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to cart'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  void _buyNow(Product product) async {
    try {
      // Add to cart first
      await ref.read(cartProvider.notifier).addToCart(
        product,
        quantity: _quantity,
      );
      
      // Navigate to checkout
      if (mounted) {
        context.go('/cart/checkout');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _shareProduct(Product product) {
    // Implement product sharing
    // This would use the share_plus package
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _imageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}