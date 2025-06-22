import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/checkout/delivery_options.dart';
import '../../widgets/checkout/order_summary.dart';
import '../../widgets/checkout/cod_info_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedDeliveryOption = 'hostel';
  String _selectedPaymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressProvider.notifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final addressState = ref.watch(addressProvider);
    
    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: cartState.when(
            data: (cart) => cart.isEmpty 
                ? _buildEmptyCart()
                : _buildCheckoutContent(cart, checkoutState, addressState),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
            error: (error, stack) => _buildErrorWidget(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutContent(cart, checkoutState, addressState) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildOrderSummarySection(cart),
                ),
                
                const SizedBox(height: 20),
                
                // Delivery Options
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildDeliverySection(),
                ),
                
                const SizedBox(height: 20),
                
                // Payment Method
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildPaymentSection(),
                ),
                
                const SizedBox(height: 20),
                
                // Additional Notes
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _buildNotesSection(),
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        
        // Bottom Checkout Bar
        _buildBottomCheckoutBar(cart, checkoutState),
      ],
    );
  }

  Widget _buildOrderSummarySection(cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderSummaryWidget(cart: cart),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Delivery Options',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Delivery Options
            _buildDeliveryOption(
              'hostel',
              'Hostel Delivery',
              'Direct delivery to your hostel room',
              Icons.home_outlined,
              'Free',
              AppColors.accentGreen,
            ),
            const SizedBox(height: 12),
            _buildDeliveryOption(
              'campus',
              'Campus Pickup',
              'Pickup from designated campus points',
              Icons.location_on_outlined,
              'Free',
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildDeliveryOption(
              'gate',
              'Main Gate Pickup',
              'Pickup from college main gate',
              Icons.exit_to_app,
              'Free',
              AppColors.warningOrange,
            ),
            
            // Address Input for Hostel Delivery
            if (_selectedDeliveryOption == 'hostel') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Hostel Room Details',
                  hintText: 'e.g., Block A, Room 201, 2nd Floor',
                  prefixIcon: Icon(Icons.room),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    String price,
    Color color,
  ) {
    final isSelected = _selectedDeliveryOption == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryOption = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cash on Delivery Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    AppColors.accentGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGreen),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.money,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cash on Delivery',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Pay when you receive your order',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // COD Info Card
            const CODInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note_add,
                    color: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Special Instructions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special instructions for delivery (optional)...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCheckoutBar(cart, checkoutState) {
    return SlideInUp(
      delay: const Duration(milliseconds: 1000),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBlue,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
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
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '₹${cart.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentGreen),
                    ),
                    child: const Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Place Order Button
              GradientButton(
                text: checkoutState.isLoading ? 'Placing Order...' : 'Place Order',
                onPressed: checkoutState.isLoading ? null : _placeOrder,
                gradient: AppTheme.primaryGradient,
                isLoading: checkoutState.isLoading,
                icon: const Icon(
                  Icons.shopping_cart_checkout,
                  size: 20,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Terms Text
              const Text(
                'By placing order, you agree to our Terms & Conditions',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
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
            'Error loading checkout',
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
        ],
      ),
    );
  }

  void _placeOrder() async {
    // Validate delivery address for hostel delivery
    if (_selectedDeliveryOption == 'hostel' && 
        _addressController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your hostel room details');
      return;
    }

    try {
      final orderData = {
        'deliveryType': _selectedDeliveryOption,
        'deliveryAddress': _selectedDeliveryOption == 'hostel' 
            ? _addressController.text.trim()
            : _getDeliveryAddressForType(_selectedDeliveryOption),
        'notes': _notesController.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
      };

      await ref.read(checkoutProvider.notifier).placeOrder(orderData);
      
      if (mounted) {
        context.go('/cart/checkout/confirmation');
      }
    } catch (e) {
      _showErrorDialog('Failed to place order: ${e.toString()}');
    }
  }

  String _getDeliveryAddressForType(String deliveryType) {
    switch (deliveryType) {
      case 'campus':
        return 'Campus Pickup Point - LEAD College';
      case 'gate':
        return 'Main Gate - LEAD College of Management';
      default:
        return '';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlue,
        title: const Text(
          'Error',
          style: TextStyle(color: AppColors.errorRed),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryGold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}