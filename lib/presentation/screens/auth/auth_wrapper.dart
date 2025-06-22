import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/common/gradient_button.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                FadeInDown(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGold.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            size: 50,
                            color: AppColors.deepBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.goldGradient.createShader(bounds),
                          child: Text(
                            'LEAD KART',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to LEAD College E-Commerce',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Auth Options
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.cardBlue.withOpacity(0.8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Choose Your Role',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Customer Options
                        _buildRoleCard(
                          context,
                          title: 'Student/Customer',
                          subtitle: 'Browse and buy products',
                          icon: Icons.person_outline,
                          color: AppColors.primaryBlue,
                          onLoginTap: () => context.go('/auth/login?role=customer'),
                          onSignupTap: () => context.go('/auth/register?role=customer'),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Seller Options
                        _buildRoleCard(
                          context,
                          title: 'Seller/Vendor',
                          subtitle: 'Sell your products',
                          icon: Icons.store_outlined,
                          color: AppColors.accentGreen,
                          onLoginTap: () => context.go('/auth/login?role=seller'),
                          onSignupTap: () => context.go('/auth/register?role=seller'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Terms and Privacy
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onLoginTap,
    required VoidCallback onSignupTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onLoginTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    foregroundColor: color,
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: 'Sign Up',
                  onPressed: onSignupTap,
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}