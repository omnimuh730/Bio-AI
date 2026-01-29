import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'quick_tile.dart';

class CaptureQuickSwitch extends StatelessWidget {
  final bool open;
  final VoidCallback onClose;
  final VoidCallback onDashboard;
  final VoidCallback onPlanner;
  final VoidCallback onAnalytics;
  final VoidCallback onSettings;

  const CaptureQuickSwitch({
    super.key,
    required this.open,
    required this.onClose,
    required this.onDashboard,
    required this.onPlanner,
    required this.onAnalytics,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (!open) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick Switch',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kTextMain,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 260,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          QuickTile(
                            icon: Icons.home_filled,
                            label: 'Dashboard',
                            onTap: onDashboard,
                          ),
                          QuickTile(
                            icon: Icons.calendar_month,
                            label: 'Planner',
                            onTap: onPlanner,
                          ),
                          QuickTile(
                            icon: Icons.bar_chart,
                            label: 'Analytics',
                            onTap: onAnalytics,
                          ),
                          QuickTile(
                            icon: Icons.person_outline,
                            label: 'Settings',
                            onTap: onSettings,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
