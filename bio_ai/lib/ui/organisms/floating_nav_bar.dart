import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onFabTapped;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onFabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.calendar_month_outlined, 1),
                    const SizedBox(width: 40),
                    _buildNavItem(Icons.bar_chart, 2),
                    _buildNavItem(Icons.person_outline, 3),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onFabTapped,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.textMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgBody, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemTapped(index),
        customBorder: const CircleBorder(),
        radius: 25,
        child: Container(
          width: 50,
          height: 60,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isSelected ? AppColors.textMain : AppColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
