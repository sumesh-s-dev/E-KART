import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/seller/dashboard_stats.dart';
import '../../widgets/seller/recent_orders.dart';
import '../../widgets/seller/quick_actions.dart';

class SellerDashboard extends ConsumerStatefulWidget {
  const SellerDashboard({super.key});

  @override
  ConsumerState<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends ConsumerState<SellerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDashboardData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  void _loadDashboardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerProvider);

    return Scaffold(
      backgroundColor: AppColors.deepBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                _buildSliverAppBar(),
                
                // Quick Actions
                SliverToBoxAdapter(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: const QuickActions(),
                  ),
                ),
                
                // Dashboard Stats
                SliverToBoxAdapter(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: sellerState.when(
                      data: (dashboard) => DashboardStats(
                        stats: dashboard.stats,
                      ),
                      loading: () => _buildStatsLoading(),
                      error: (error, stack) => _buildStatsError(),
                    ),
                  ),
                ),
                
                // Sales Chart
                SliverToBoxAdapter(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildSalesChart(),
                  ),
                ),
                
                // Recent Orders
                SliverToBoxAdapter(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: sellerState.when(
                      data: (dashboard) => RecentOrders(
                        orders: dashboard.recentOrders,
                      ),
                      loading: () => _buildOrdersLoading(),
                      error: (error, stack) => _buildOrdersError(),
                    ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/seller/add-product'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.deepBlue,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: FadeInDown(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller Dashboard',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back! Here\'s your business overview',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/profile'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 6),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.primaryGold],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue.withOpacity(0.3),
                          AppColors.primaryGold.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
    );
  }

  Widget _buildStatsError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: const Text(
        'Failed to load dashboard stats',
        style: TextStyle(color: AppColors.errorRed),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOrdersLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
    );
  }

  Widget _buildOrdersError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
      ),
      child: const Text(
        'Failed to load recent orders',
        style: TextStyle(color: AppColors.errorRed),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}