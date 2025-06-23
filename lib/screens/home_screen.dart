import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/product_bloc.dart';
import '../blocs/order_bloc.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/order_card.dart';
import '../widgets/custom_button.dart';
import 'product_add_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _currentUserId;
  String? _currentRole;
  String _selectedCategory = '';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    final authState = context.read<AuthBloc>().state;
    if (authState is CustomerAuthenticated) {
      _currentUserId = authState.user.userId;
      _currentRole = 'customer';
      context.read<ProductBloc>().add(LoadProducts());
    } else if (authState is SellerAuthenticated) {
      _currentUserId = authState.seller.sellerId;
      _currentRole = 'seller';
      context
          .read<OrderBloc>()
          .add(LoadOrders(userId: _currentUserId, role: _currentRole));
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load data based on selected tab
    if (_currentRole == 'seller') {
      if (index == 0) {
        context
            .read<OrderBloc>()
            .add(LoadOrders(userId: _currentUserId, role: _currentRole));
      } else if (index == 1) {
        context.read<ProductBloc>().add(LoadProducts());
      }
    } else {
      if (index == 0) {
        context.read<ProductBloc>().add(LoadProducts());
      } else if (index == 1) {
        context
            .read<OrderBloc>()
            .add(LoadOrders(userId: _currentUserId, role: _currentRole));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      title: Text(
        _getAppBarTitle(),
        style: AppConstants.headingStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_currentRole == 'customer') ...[
          IconButton(
            icon:
                const Icon(Icons.search, color: AppConstants.textPrimaryColor),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list,
                color: AppConstants.textPrimaryColor),
            onPressed: () => _showCategoryFilter(),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.person, color: AppConstants.textPrimaryColor),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    if (_currentRole == 'seller') {
      switch (_currentIndex) {
        case 0:
          return 'Orders';
        case 1:
          return 'My Products';
        case 2:
          return 'Profile';
        default:
          return AppConstants.appName;
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return 'Products';
        case 1:
          return 'My Orders';
        case 2:
          return 'Profile';
        default:
          return AppConstants.appName;
      }
    }
  }

  Widget _buildBody() {
    if (_currentRole == 'seller') {
      switch (_currentIndex) {
        case 0:
          return _buildOrdersView();
        case 1:
          return _buildProductsView();
        case 2:
          return const ProfileScreen();
        default:
          return _buildOrdersView();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return _buildProductsView();
        case 1:
          return _buildOrdersView();
        case 2:
          return const ProfileScreen();
        default:
          return _buildProductsView();
      }
    }
  }

  Widget _buildProductsView() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.accentColor,
            ),
          );
        } else if (state is ProductLoaded) {
          return ProductGrid(
            products: state.products,
            onProductTap: () {
              // Navigate to product detail
            },
            onAddToCart: () {
              // Add to cart functionality
            },
          );
        } else if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading products',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppConstants.captionStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<ProductBloc>().add(LoadProducts());
                  },
                  icon: Icons.refresh,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrdersView() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.accentColor,
            ),
          );
        } else if (state is OrderLoaded) {
          return OrderList(
            orders: state.orders,
            isSeller: _currentRole == 'seller',
            onOrderTap: () {
              // Navigate to order detail
            },
            onStatusUpdate: () {
              // Update order status
            },
          );
        } else if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading orders',
                  style: AppConstants.subheadingStyle.copyWith(
                    color: AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppConstants.captionStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<OrderBloc>().add(
                          LoadOrders(
                              userId: _currentUserId, role: _currentRole),
                        );
                  },
                  icon: Icons.refresh,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppConstants.accentColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: _currentRole == 'seller'
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory),
                  label: 'Products',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Products',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentRole == 'seller' && _currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProductAddScreen(),
            ),
          );
        },
        backgroundColor: AppConstants.accentColor,
        child: const Icon(
          Icons.add,
          color: AppConstants.textPrimaryColor,
        ),
      );
    }
    return null;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text(
          'Search Products',
          style: AppConstants.subheadingStyle,
        ),
        content: TextField(
          controller: _searchController,
          style: AppConstants.bodyStyle,
          decoration: const InputDecoration(
            hintText: 'Enter product name...',
            hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
              context.read<ProductBloc>().add(LoadProducts());
            },
            child: Text(
              'Cancel',
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          CustomButton(
            text: 'Search',
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductBloc>().add(
                    FilterProducts(searchQuery: _searchQuery),
                  );
            },
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text(
          'Filter by Category',
          style: AppConstants.subheadingStyle,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.productCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.productCategories[index];
              return ListTile(
                title: Text(
                  category,
                  style: AppConstants.bodyStyle,
                ),
                selected: _selectedCategory == category,
                selectedTileColor: AppConstants.accentColor.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.of(context).pop();
                  context.read<ProductBloc>().add(
                        FilterProducts(category: category),
                      );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedCategory = '';
              });
              context.read<ProductBloc>().add(LoadProducts());
            },
            child: Text(
              'Clear',
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
