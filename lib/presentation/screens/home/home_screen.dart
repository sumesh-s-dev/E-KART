import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/category_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/search_bar_widget.dart';
import '../../widgets/home/category_section.dart';
import '../../widgets/home/promotional_banners.dart';
import '../../widgets/home/featured_products.dart';
import '../../widgets/product/product_grid.dart';
import '../../widgets/layout/main_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _fabController;
  
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupScrollListener();
    _loadInitialData();
  }

  void _initAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      } else if (_scrollController.offset <= 300 && _showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    });
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(featuredProductsProvider.notifier).loadFeaturedProducts();
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final featuredProductsState = ref.watch(featuredProductsProvider);
    final categoriesState = ref.watch(categoryProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primaryGold,
          backgroundColor: AppColors.cardBlue,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: HomeAppBar(
                  cartItemCount: cartItemCount,
                  onSearchTap: () => context.go('/search'),
                  onCartTap: () => context.go('/cart'),
                  onProfileTap: () => context.go('/profile'),
                ),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: SearchBarWidget(
                    onSearch: (query) => context.go('/search?q=$query'),
                    onTap: () => context.go('/search'),
                  ),
                ),
              ),
              
              // Promotional Banners
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: const PromotionalBanners(),
                ),
              ),
              
              // Categories Section
              SliverToBoxAdapter(
                child: FadeInLeft(
                  delay: const Duration(milliseconds: 400),
                  child: CategorySection(
                    categories: categoriesState.when(
                      data: (categories) => categories,
                      loading: () => <CategoryModel>[],
                      error: (_, __) => <CategoryModel>[],
                    ),
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                      if (category == 'All') {
                        ref.read(productProvider.notifier).loadProducts();
                      } else {
                        // Load products by category
                        context.go('/category/$category');
                      }
                    },
                  ),
                ),
              ),
              
              // Featured Products Section
              SliverToBoxAdapter(
                child: FadeInRight(
                  delay: const Duration(milliseconds: 500),
                  child: FeaturedProducts(
                    products: featuredProductsState.when(
                      data: (products) => products,
                      loading: () => [],
                      error: (_, __) => [],
                    ),
                    isLoading: featuredProductsState.isLoading,
                  ),
                ),
              ),
              
              // All Products Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Products',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/products'),
                        child: const Text(
                          'View All',
                          style: TextStyle(color: AppColors.primaryGold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Products Grid
              productState.when(
                data: (products) => ProductGrid(
                  products: products.take(6).toList(), // Show only 6 on home
                  isLoading: false,
                ),
                loading: () => const ProductGrid(
                  products: [],
                  isLoading: true,
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: _buildErrorWidget(error.toString()),
                ),
              ),
              
              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: _scrollToTop,
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.deepBlue,
          icon: const Icon(Icons.keyboard_arrow_up),
          label: const Text('Top'),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
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
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(productProvider.notifier).loadProducts();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(productProvider.notifier).refreshProducts(),
      ref.read(featuredProductsProvider.notifier).loadFeaturedProducts(),
      ref.read(categoryProvider.notifier).loadCategories(),
    ]);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}