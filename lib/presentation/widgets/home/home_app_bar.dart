import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';

class HomeAppBar extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  const HomeAppBar({
    super.key,
    required this.cartItemCount,
    required this.onSearchTap,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: SafeArea(
        bottom: false,
        child: FadeInDown(
          child: Row(
            children: [
              // Greeting and Logo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello! 👋',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                            colors: [AppColors.primaryGold, Colors.white],
                          ).createShader(bounds),
                      child: Text(
                        'LEAD KART',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  // Search Button
                  _buildActionButton(
                    icon: Icons.search,
                    onTap: onSearchTap,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Cart Button with Badge
                  _buildCartButton(),
                  
                  const SizedBox(width: 12),
                  
                  // Profile Button
                  _buildActionButton(
                    icon: Icons.person_outline,
                    onTap: onProfileTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBlue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: onCartTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBlue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 20,
            ),
            if (cartItemCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}