import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import '../models/food_item.dart';

class CaptureBarcodeOverlay extends StatefulWidget {
  final bool open;
  final bool found;
  final bool scanning;
  final FoodItem? item;
  final VoidCallback? onAdd;
  final VoidCallback onClose;
  final VoidCallback onNotFound;
  final void Function(BarcodeCapture)? onBarcodeDetected;

  const CaptureBarcodeOverlay({
    super.key,
    required this.open,
    required this.found,
    required this.scanning,
    required this.item,
    required this.onAdd,
    required this.onClose,
    required this.onNotFound,
    this.onBarcodeDetected,
  });

  @override
  State<CaptureBarcodeOverlay> createState() => _CaptureBarcodeOverlayState();
}

class _CaptureBarcodeOverlayState extends State<CaptureBarcodeOverlay> {
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.open && widget.scanning) {
      _initializeScanner();
    }
  }

  @override
  void didUpdateWidget(CaptureBarcodeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _initializeScanner();
    } else if (!widget.open && oldWidget.open) {
      _disposeScanner();
    }
  }

  @override
  void dispose() {
    _disposeScanner();
    super.dispose();
  }

  void _initializeScanner() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.all],
    );
  }

  void _disposeScanner() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanner view when scanning
          if (widget.scanning && _controller != null)
            Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (widget.onBarcodeDetected != null) {
                    widget.onBarcodeDetected!(capture);
                  }
                },
              ),
            )
          else
            // Empty frame when not scanning or loading
            Container(
              width: 240,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            widget.found
                ? 'Barcode detected'
                : widget.scanning
                ? 'Scanning barcode...'
                : 'Looking up...',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (widget.found && widget.item != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.item!.name,
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.item!.cals} kcal - ${widget.item!.protein}g Protein - ${widget.item!.fat}g Fat',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textMain,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Item',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onNotFound,
            child: Text(
              'Barcode not found',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: AppColors.textMain,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
