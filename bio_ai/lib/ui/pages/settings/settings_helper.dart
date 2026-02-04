import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';
import 'package:bio_ai/services/streaming_service.dart';

import 'package:bio_ai/ui/pages/settings/settings_state.dart';
import 'package:bio_ai/ui/pages/settings/core/core_components.dart';

// ---------- Helpers (inlined) ----------
Future<void> openSubscriptionModal(
  BuildContext context,
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(String) showToast,
  void Function(VoidCallback) setParentState,
) async {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SettingsModalShell(
            title: 'Subscription',
            primaryText: 'Apply Plan',
            onPrimary: () {
              Navigator.pop(context);
              showToast('Plan updated to ${s.planLabel(s.selectedPlan)}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current plan: ${s.planLabel(s.selectedPlan)}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                SettingsPlanOptions(
                  selectedPlan: s.selectedPlan,
                  onPlanSelected: (plan) {
                    setParentState(() => s.selectedPlan = plan);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> openExportModal(
  BuildContext context,
  void Function(String) showToast,
) async {
  showDialog(
    context: context,
    builder: (context) {
      return SettingsModalShell(
        title: 'Export Data',
        primaryText: 'Download CSV',
        onPrimary: () {
          Navigator.pop(context);
          showToast('Export started');
        },
        child: Text(
          'CSV export ready. This is a mock download.',
          style: AppTextStyles.bodySmall,
        ),
      );
    },
  );
}

Future<void> openFindDevicesModal(
  BuildContext context,
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(String) showToast,
  void Function(VoidCallback) setParentState,
) async {
  // If running against the streaming mock in dev/stage, show that backend list
  // Try backend first (force request). If it responds (even empty list) show mock modal.
  try {
    final available = await s.fetchAvailableDevices(
      force: true,
      throwOnError: true,
    );
    if (!context.mounted) return;
    // Keep a persistent local list so dialog switches reflect changes.
    var localAvailable = List<String>.from(available);
    // Show all supported devices; toggle indicates availability.
    final deviceNames = s.streamingMap.values.toList();
    // Sync parent so Device Sync panel reflects current availability.
    setParentState(() => s.updateAvailable(localAvailable));
    // toast success
    showToast(
      'Fetched ${available.length} available device(s) from mock backend',
    );
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> toggleByName(String name, bool value) async {
            final key = s.keyForStreamingName(name);
            if (key == null) return;

            // Optimistic UI update so the modal feels responsive
            if (value) {
              if (!localAvailable.contains(name)) localAvailable.add(name);
            } else {
              localAvailable.remove(name);
            }
            setModalState(() {});

            // Update backend availability
            final ok = await s.setDeviceExposure(key, value, force: true);
            if (!ok) {
              // Revert optimistic update
              if (value) {
                localAvailable.remove(name);
              } else {
                if (!localAvailable.contains(name)) localAvailable.add(name);
              }
              setModalState(() {});
              showToast('Backend error while updating $name');
              return;
            }

            // Enforce single local connection in the app and update parent's available list
            if (value) {
              setParentState(() {
                s.devices.forEach((k, v) {
                  v.connected = false;
                  v.lastSync = '';
                });
                final dev = s.devices[key];
                if (dev != null) {
                  dev.connected = true;
                  dev.lastSync = 'just now';
                }
                s.updateAvailable(localAvailable);
              });
              StreamingService.instance.setSelectedDevice(name);
              // Ensure the streaming service is running so dashboard receives data
              StreamingService.instance.start(force: true);
              showToast('Connected $name');
            } else {
              setParentState(() {
                final dev = s.devices[key];
                if (dev != null) {
                  final wasConnected = dev.connected;
                  dev.connected = false;
                  dev.lastSync = '';
                  if (wasConnected) {
                    StreamingService.instance.setSelectedDevice(null);
                    StreamingService.instance.stop();
                  }
                }
                s.updateAvailable(localAvailable);
              });
              showToast('Removed $name');
            }

            // Refresh authoritative list from backend
            localAvailable = await s.fetchAvailableDevices(force: true);
            // Sync parent again in case backend differs
            setParentState(() => s.updateAvailable(localAvailable));
            setModalState(() {});
          }

          final entries = deviceNames.isNotEmpty ? deviceNames : localAvailable;

          return AlertDialog(
            title: const Text('Mock Available Devices'),
            content: SizedBox(
              width: double.maxFinite,
              child: entries.isEmpty
                  ? const Text('No devices available')
                  : ListView(
                      shrinkWrap: true,
                      children: entries.map((name) {
                        final key = s.keyForStreamingName(name);
                        return ListTile(
                          title: Text(name),
                          trailing: Switch(
                            value: localAvailable.contains(name),
                            onChanged: key == null
                                ? null
                                : (v) async => await toggleByName(name, v),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
    return;
  } catch (e) {
    // If backend is unreachable, fall back to BLE flow below
    showToast('Could not contact mock backend: $e');
  }

  final ble = ref.read(bleServiceProvider);
  final ok = await ble.ensurePermissions();
  await updateBtPermission(ref, s, setParentState);

  if (!ok) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth permission required'),
        content: const Text(
          'This action requires Bluetooth access. Please enable Bluetooth permissions in system settings and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    return;
  }

  showToast('Fetching connected Bluetooth devices...');
  final supported = await ble.isSupported();
  if (!supported) {
    showToast('Bluetooth not supported on this device');
    return;
  }

  final devices = await ble.connectedDeviceSummaries();
  if (devices.isEmpty) {
    showToast('No connected devices found');
    return;
  }

  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Connected devices'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: devices
              .map(
                (d) => ListTile(
                  title: Text(d['name'] ?? 'Unknown'),
                  subtitle: Text(d['id'] ?? '-'),
                  trailing: const Text('-'),
                  onTap: () => showToast('${d['name'] ?? d['id']} selected'),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> updateBtPermission(
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(VoidCallback) setParentState,
) async {
  try {
    final status = await ref.read(bleServiceProvider).permissionStatus();
    setParentState(() => s.btPermissionStatus = status);
  } catch (_) {
    setParentState(() => s.btPermissionStatus = null);
  }
}

Future<void> requestBluetoothPermission(
  WidgetRef ref,
  SettingsStateHolder s,
  void Function(VoidCallback) setParentState,
  void Function(String) showToast,
) async {
  try {
    final ok = await ref.read(bleServiceProvider).ensurePermissions();
    await updateBtPermission(ref, s, setParentState);
    showToast(
      ok ? 'Bluetooth permission granted' : 'Bluetooth permission denied',
    );
  } catch (e) {
    showToast('Permission request failed: $e');
  }
}

Future<void> testTorch(WidgetRef ref, void Function(String) showToast) async {
  final torch = ref.read(torchServiceProvider);
  try {
    await torch.turnOn();
    showToast('Torch on');
    await Future.delayed(const Duration(seconds: 1));
    await torch.turnOff();
    showToast('Torch off');
  } catch (e) {
    showToast('Torch error: $e');
  }
}

Future<void> testGps(WidgetRef ref, void Function(String) showToast) async {
  final pos = await ref.read(gpsServiceProvider).getCurrentPosition();
  if (pos == null) {
    showToast('Location denied or unavailable');
    return;
  }
  showToast(
    'Location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
  );
}

Future<void> testNetwork(WidgetRef ref, void Function(String) showToast) async {
  try {
    final res = await ref
        .read(networkServiceProvider)
        .get('https://httpbin.org/get');
    showToast('Network OK: ${res.statusCode}');
  } catch (e) {
    showToast('Network error: $e');
  }
}

Future<void> testCapture(WidgetRef ref, void Function(String) showToast) async {
  try {
    final camera = ref.read(cameraServiceProvider);
    await camera.initialize();
    final file = await camera.takePhoto();
    await ref
        .read(visionRepositoryProvider)
        .queuePhoto(file, meta: {'source': 'diagnostic'});
    showToast('Captured & queued: ${file.path}');
  } catch (e) {
    showToast('Capture error: $e');
  }
}

Future<void> openDeleteModal(
  BuildContext context,
  SettingsStateHolder s,
  void Function(String) showToast,
) async {
  s.deleteController.clear();
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SettingsModalShell(
            title: 'Delete Account',
            primaryText: 'Confirm Delete',
            primaryColor: const Color(0xFFEF4444),
            primaryEnabled:
                s.deleteController.text.trim().toUpperCase() == 'DELETE',
            onPrimary: () {
              Navigator.pop(context);
              showToast('Account deleted (mock)');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently remove your health data (mock).',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                Text('Type DELETE to confirm.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                TextField(
                  controller: s.deleteController,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
