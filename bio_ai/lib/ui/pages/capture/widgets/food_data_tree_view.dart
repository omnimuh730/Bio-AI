import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bio_ai/core/theme/app_text_styles.dart';

/// A Material Design tree view widget for displaying dynamic food data
/// from barcode scanning or image recognition results.
class FoodDataTreeView extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final VoidCallback onAdd;
  final VoidCallback onClose;
  final String? title;

  const FoodDataTreeView({
    super.key,
    required this.foodData,
    required this.onAdd,
    required this.onClose,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Extract display name from common fields
    // Priority: food_entry_name (image recognition) > food_name (barcode) > nested food.food_name
    final displayName =
        foodData['food_entry_name'] ??
        foodData['food_name'] ??
        (foodData['food'] as Map?)?['food_name'] ??
        foodData['name'] ??
        'Food Item';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_tree_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title ?? 'Food Data',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName.toString(),
                              style: AppTextStyles.label.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Tree content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: _buildTreeNode(foodData, 0, true),
                  ),
                ),

                // Add button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add to My Foods'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTreeNode(dynamic data, int depth, bool isRoot) {
    if (data is Map) {
      return _buildMapNode(Map<String, dynamic>.from(data), depth, isRoot);
    } else if (data is List) {
      return _buildListNode(data, depth);
    } else {
      return _buildValueNode(data);
    }
  }

  Widget _buildMapNode(Map<String, dynamic> map, int depth, bool isRoot) {
    final entries = map.entries.toList();

    // Sort entries to show important fields first
    entries.sort((a, b) {
      final priority = [
        'food_name',
        'brand_name',
        'food_type',
        'calories',
        'protein',
        'carbohydrate',
        'fat',
        'serving_description',
      ];
      final aIdx = priority.indexOf(a.key);
      final bIdx = priority.indexOf(b.key);
      if (aIdx >= 0 && bIdx >= 0) return aIdx.compareTo(bIdx);
      if (aIdx >= 0) return -1;
      if (bIdx >= 0) return 1;
      return a.key.compareTo(b.key);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((entry) {
        return _TreeTile(
          keyName: entry.key,
          value: entry.value,
          depth: depth,
          buildChild: () => _buildTreeNode(entry.value, depth + 1, false),
        );
      }).toList(),
    );
  }

  Widget _buildListNode(List<dynamic> list, int depth) {
    if (list.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 8.0),
        child: Text(
          '[ empty ]',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.asMap().entries.map((entry) {
        return _TreeTile(
          keyName: '[${entry.key}]',
          value: entry.value,
          depth: depth,
          isArrayItem: true,
          buildChild: () => _buildTreeNode(entry.value, depth + 1, false),
        );
      }).toList(),
    );
  }

  Widget _buildValueNode(dynamic value) {
    return Text(
      value?.toString() ?? 'null',
      style: const TextStyle(color: Colors.white),
    );
  }
}

class _TreeTile extends StatefulWidget {
  final String keyName;
  final dynamic value;
  final int depth;
  final bool isArrayItem;
  final Widget Function() buildChild;

  const _TreeTile({
    required this.keyName,
    required this.value,
    required this.depth,
    required this.buildChild,
    this.isArrayItem = false,
  });

  @override
  State<_TreeTile> createState() => _TreeTileState();
}

class _TreeTileState extends State<_TreeTile> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand first level and important fields
    _expanded = widget.depth < 1 || _isImportantField(widget.keyName);
  }

  bool _isImportantField(String key) {
    return [
      'food_name',
      'brand_name',
      'calories',
      'protein',
      'carbohydrate',
      'fat',
      'serving_description',
      'servings',
    ].contains(key);
  }

  bool get _isExpandable => widget.value is Map || widget.value is List;

  String _formatKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  Color _getValueColor() {
    final value = widget.value;
    if (value is num) return const Color(0xFF82AAFF); // Blue for numbers
    if (value is bool) return const Color(0xFFFFCB6B); // Yellow for booleans
    if (value is String && value.startsWith('http')) {
      return const Color(0xFF89DDFF); // Cyan for URLs
    }
    return Colors.white; // Default white
  }

  IconData _getIcon() {
    if (widget.value is Map) return Icons.data_object;
    if (widget.value is List) return Icons.data_array;
    if (widget.value is num) return Icons.numbers;
    if (widget.value is bool) return Icons.toggle_on_outlined;
    if (widget.value is String && widget.value.startsWith('http')) {
      return Icons.link;
    }
    return Icons.text_fields;
  }

  @override
  Widget build(BuildContext context) {
    final isExpandable = _isExpandable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isExpandable
              ? () => setState(() => _expanded = !_expanded)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            margin: EdgeInsets.only(left: widget.depth * 12.0),
            decoration: BoxDecoration(
              color: _expanded && isExpandable
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpandable)
                  Icon(
                    _expanded ? Icons.expand_more : Icons.chevron_right,
                    color: Colors.white70,
                    size: 20,
                  )
                else
                  Icon(_getIcon(), color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: isExpandable
                      ? Text(
                          _formatKey(widget.keyName),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_formatKey(widget.keyName)}: ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: widget.value?.toString() ?? 'null',
                                style: TextStyle(
                                  color: _getValueColor(),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (isExpandable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.value is Map
                          ? '${(widget.value as Map).length} fields'
                          : '${(widget.value as List).length} items',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded && isExpandable)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: widget.buildChild(),
          ),
      ],
    );
  }
}
