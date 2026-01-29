import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'planner_menu_card.dart';

class PlannerEatOutView extends StatefulWidget {
  const PlannerEatOutView({super.key});

  @override
  State<PlannerEatOutView> createState() => _PlannerEatOutViewState();
}

class _PlannerEatOutViewState extends State<PlannerEatOutView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1A10B981),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Text(
                  'Near 5th Avenue, NYC',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Search menu (e.g. Starbucks)',
              hintStyle: GoogleFonts.inter(fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu Coach',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          PlannerMenuCard(
            brandColor: const Color(0xFF00704A),
            brand: 'Starbucks',
            title: 'Spinach, Feta & Cage-Free Egg Wrap',
            desc:
                'High protein, moderate carbs. Fits perfectly into your remaining post-workout macros.',
            calories: '290 kcal - 19g Protein',
            match: '98% Match',
            best: true,
            selected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          const SizedBox(height: 16),
          PlannerMenuCard(
            brandColor: const Color(0xFFA52A2A),
            brand: 'Chipotle',
            title: 'Lifestyle Bowl (Paleo)',
            desc:
                'Good choice, but ask for light dressing to stay under your fat limit.',
            calories: '500 kcal - 42g Protein',
            match: '85% Match',
            selected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ],
      ),
    );
  }
}
