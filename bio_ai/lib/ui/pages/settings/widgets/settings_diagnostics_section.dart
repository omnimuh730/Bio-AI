import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/core/theme/app_colors.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:bio_ai/app/di/injectors.dart';

class SettingsDiagnosticsSection extends ConsumerWidget {
  final VoidCallback onTestTorch;
  final VoidCallback onTestGps;
  final VoidCallback onTestNetwork;
  final VoidCallback onShowDevices;
  final VoidCallback onRequestPermission;
  final VoidCallback onTestCapture;
  final String btPermissionLabel;
  final VoidCallback onRefresh;

  const SettingsDiagnosticsSection({
    super.key,
    required this.onTestTorch,
    required this.onTestGps,
    required this.onTestNetwork,
    required this.onShowDevices,
    required this.onRequestPermission,
    required this.onTestCapture,
    required this.btPermissionLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnostics',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: onTestTorch,
                child: const Text('Torch'),
              ),
              ElevatedButton(onPressed: onTestGps, child: const Text('GPS')),
              ElevatedButton(
                onPressed: onTestNetwork,
                child: const Text('Network'),
              ),
              Chip(label: Text('Bluetooth: $btPermissionLabel')),
              ElevatedButton(
                onPressed: onShowDevices,
                child: const Text('Show Devices'),
              ),
              TextButton(
                onPressed: onRequestPermission,
                child: const Text('Request Permission'),
              ),
              ElevatedButton(
                onPressed: onTestCapture,
                child: const Text('Capture'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Connected Devices',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final devicesAsync = ref.watch(
                      connectedDeviceSummariesProvider,
                    );
                    return devicesAsync.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return Text(
                            'No connected devices',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        }
                        return Column(
                          children: list
                              .map(
                                (d) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(d['name'] ?? 'Unknown'),
                                  subtitle: Text(d['id'] ?? '-'),
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${d['name'] ?? d['id']} selected',
                                          ),
                                        ),
                                      ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Unable to load devices: ${e.toString()}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onRequestPermission,
                            child: const Text('Request Permission'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
