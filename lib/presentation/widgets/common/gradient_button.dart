import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool isLoading;
  final Widget? icon;
  final MainAxisSize mainAxisSize;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient = const LinearGradient(
      colors: [AppColors.primaryBlue, Color(0xFF1976D2)],
    ),
    this.textColor = Colors.white,
    this.width,
    this.height = AppDimensions.buttonHeightMedium,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppDimensions.radiusMedium),
    ),
    this.isLoading = false,
    this.icon,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: widget.onPressed != null ? _onTapCancel : null,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.onPressed != null
                    ? widget.gradient
                    : LinearGradient(
                        colors: [
                          AppColors.grey600,
                          AppColors.grey700,
                        ],
                      ),
                borderRadius: widget.borderRadius,
                boxShadow: widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: widget.gradient.colors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: widget.borderRadius,
                  child: Container(
                    padding: widget.padding,
                    child: Row(
                      mainAxisSize: widget.mainAxisSize,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor,
                              ),
                            ),
                          )
                        else ...[
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: widget.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}