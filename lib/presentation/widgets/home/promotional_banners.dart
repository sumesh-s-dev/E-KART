import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';

class PromotionalBanners extends StatelessWidget {
  const PromotionalBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = [
      _BannerData(
        title: 'Cash on Delivery',
        subtitle: 'Pay when you receive!',
        description: 'No online payments required. Safe & Secure.',
        icon: Icons.payments_outlined,
        color: AppColors.accentGreen,
        gradient: const LinearGradient(
          colors: [AppColors.accentGreen, Color(0xFF2E7D32)],
        ),
      ),
      _BannerData(
        title: 'Hostel Delivery',
        subtitle: 'Direct to your room',
        description: 'Get products delivered to your hostel room.',
        icon: Icons.local_shipping_outlined,
        color: AppColors.primaryBlue,
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF1976D2)],
        ),
      ),
      _BannerData(
        title: 'Student Deals',
        subtitle: 'Exclusive offers',
        description: 'Special prices for LEAD students.',
        icon: Icons.school_outlined,
        color: AppColors.warningOrange,
        gradient: const LinearGradient(
          colors: [AppColors.warningOrange, Color(0xFFE65100)],
        ),
      ),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Swiper(
          itemCount: banners.length,
          autoplay: true,
          autoplayDelay: 4000,
          viewportFraction: 0.9,
          scale: 0.9,
          itemBuilder: (context, index) {
            return _buildBannerCard(banners[index]);
          },
          pagination: SwiperPagination(
            alignment: Alignment.bottomCenter,
            builder: DotSwiperPaginationBuilder(
              activeColor: AppColors.primaryGold,
              color: Colors.white38,
              size: 8,
              activeSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard(_BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: banner.gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: banner.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Icon(
                    banner.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}