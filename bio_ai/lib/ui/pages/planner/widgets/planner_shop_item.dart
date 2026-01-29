import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PlannerShopItem extends StatefulWidget {
  final String label;
  final bool checked;

  const PlannerShopItem(this.label, this.checked, {super.key});

  @override
  State<PlannerShopItem> createState() => _PlannerShopItemState();
}

class _PlannerShopItemState extends State<PlannerShopItem> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _checked ? AppColors.accentBlue : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
              ),
              child: _checked
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _checked ? const Color(0xFFCBD5E1) : AppColors.textMain,
                decoration: _checked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
