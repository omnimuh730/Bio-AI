import 'dart:async';

import 'capture_models.dart';

class CaptureScreenStateHolder {
  bool sheetOpen = false;
  bool offlineMode = false;
  bool barcodeOpen = false;
  bool barcodeFound = false;
  bool barcodeScanning = false;
  bool quickSwitchOpen = false;
  bool scanResultOpen = false;
  bool scanProcessing = false;

  String mode = 'scan';
  final List<double> portionOptions = [0.75, 1.0, 1.5];
  final List<FoodItem> items = [];
  List<Map<String, dynamic>> scanResults = [];

  Timer? barcodeTimer;

  FoodItem? barcodeItem;
  Map<String, dynamic>? barcodeFullData;
  String? barcodePendingConfirmation;

  void dispose() {
    barcodeTimer?.cancel();
  }
}
