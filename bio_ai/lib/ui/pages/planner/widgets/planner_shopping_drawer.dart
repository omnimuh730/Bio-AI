import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'planner_shop_item.dart';

class PlannerShoppingDrawer extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final int shoppingCount;
  final VoidCallback onExport;

  const PlannerShoppingDrawer({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.shoppingCount,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    const drawerHeight = 360.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      bottom: expanded ? 0 : -(drawerHeight - 60),
      height: drawerHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Shopping List',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$shoppingCount',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const PlannerShopItem('Lemons (2)', false),
                  const PlannerShopItem('Greek Yogurt', true),
                  const PlannerShopItem('Almonds', false),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.shopping_basket),
                    label: const Text('Order or Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
