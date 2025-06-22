import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/common/gradient_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final SwiperController _swiperController = SwiperController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.shopping_cart_outlined,
      title: 'Shop with Ease',
      description: 'Browse through thousands of products from fellow students and local vendors within your campus.',
      color: AppColors.primaryBlue,
      gradient: const LinearGradient(
        colors: [AppColors.primaryBlue, Color(0xFF1976D2)],
      ),
    ),
    OnboardingItem(
      icon: Icons.payments_outlined,
      title: 'Cash on Delivery',
      description: 'No online payments, no hassle! Pay when you receive your order. Safe and secure.',
      color: AppColors.accentGreen,
      gradient: const LinearGradient(
        colors: [AppColors.accentGreen, Color(0xFF2E7D32)],
      ),
    ),
    OnboardingItem(
      icon: Icons.local_shipping_outlined,
      title: 'Fast Delivery',
      description: 'Get your orders delivered right to your hostel room or pickup from campus points.',
      color: AppColors.warningOrange,
      gradient: const LinearGradient(
        colors: [AppColors.warningOrange, Color(0xFFE65100)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              
              // Onboarding Pages
              Expanded(
                flex: 4,
                child: Swiper(
                  controller: _swiperController,
                  itemCount: _items.length,
                  onIndexChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_items[index], index);
                  },
                  loop: false,
                  pagination: null,
                  control: null,
                ),
              ),
              
              // Bottom Section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInLeft(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'LEAD ',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'KART',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInRight(
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item, int index) {
    return FadeIn(
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            BounceInDown(
              delay: Duration(milliseconds: 500 + (index * 100)),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: item.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Title
            FadeInUp(
              delay: Duration(milliseconds: 700 + (index * 100)),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description
            FadeInUp(
              delay: Duration(milliseconds: 900 + (index * 100)),
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Page Indicators
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Navigation Buttons
          Row(
            children: [
              // Previous Button
              if (_currentIndex > 0)
                Expanded(
                  child: FadeInLeft(
                    child: OutlinedButton(
                      onPressed: () => _swiperController.previous(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGold),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: AppColors.primaryGold),
                      ),
                    ),
                  ),
                ),
              
              if (_currentIndex > 0) const SizedBox(width: 16),
              
              // Next/Get Started Button
              Expanded(
                flex: _currentIndex == 0 ? 1 : 1,
                child: FadeInRight(
                  child: GradientButton(
                    text: _currentIndex == _items.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (_currentIndex == _items.length - 1) {
                        _completeOnboarding();
                      } else {
                        _swiperController.next();
                      }
                    },
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentIndex == index
            ? AppColors.primaryGold
            : Colors.white30,
      ),
    );
  }

  void _skipOnboarding() {
    context.go('/auth/login');
  }

  void _completeOnboarding() async {
    final authService = ref.read(authServiceProvider);
    await authService.setOnboardingCompleted();
    
    if (authService.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/auth/login');
    }
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Gradient gradient;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });
}