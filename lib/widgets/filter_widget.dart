import 'package:flutter/material.dart';

class FilterData {
  String? diet;
  String? mealType;
  int? maxReadyTime;

  FilterData({
    this.diet,
    this.mealType,
    this.maxReadyTime,
  });

  bool get hasAnyFilter {
    return diet != null || mealType != null || maxReadyTime != null;
  }

  void clear() {
    diet = null;
    mealType = null;
    maxReadyTime = null;
  }

  FilterData copy() {
    return FilterData(
      diet: diet,
      mealType: mealType,
      maxReadyTime: maxReadyTime,
    );
  }
}

class FilterWidget extends StatefulWidget {
  final FilterData currentFilters;
  final Function(FilterData) onFiltersChanged;

  const FilterWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late FilterData filters;

  // Daftar diet options
  final List<Map<String, String>> diets = [
    {'value': '', 'label': 'Semua Diet'},
    {'value': 'vegetarian', 'label': 'Vegetarian'},
    {'value': 'vegan', 'label': 'Vegan'},
    {'value': 'gluten free', 'label': 'Gluten Free'},
    {'value': 'ketogenic', 'label': 'Keto'},
    {'value': 'paleo', 'label': 'Paleo'},
  ];

  // Daftar meal type options
  final List<Map<String, String>> mealTypes = [
    {'value': '', 'label': 'Semua Waktu'},
    {'value': 'breakfast', 'label': 'Sarapan'},
    {'value': 'lunch', 'label': 'Makan Siang'},
    {'value': 'dinner', 'label': 'Makan Malam'},
    {'value': 'snack', 'label': 'Camilan'},
    {'value': 'dessert', 'label': 'Dessert'},
  ];

  // Daftar waktu memasak
  final List<Map<String, dynamic>> readyTimes = [
    {'value': null, 'label': 'Semua Waktu'},
    {'value': 15, 'label': 'Max 15 menit'},
    {'value': 30, 'label': 'Max 30 menit'},
    {'value': 60, 'label': 'Max 1 jam'},
    {'value': 120, 'label': 'Max 2 jam'},
  ];

  @override
  void initState() {
    super.initState();
    filters = widget.currentFilters.copy();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Resep'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diet Filter
                    const Text(
                      'Diet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...diets.map((diet) => RadioListTile<String?>(
                          title: Text(diet['label']!),
                          value: diet['value']!.isEmpty ? null : diet['value'],
                          groupValue: filters.diet,
                          onChanged: (value) {
                            setDialogState(() {
                              filters.diet = value;
                            });
                          },
                          dense: true,
                        )),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Meal Type Filter
                    const Text(
                      'Waktu Makan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...mealTypes.map((mealType) => RadioListTile<String?>(
                          title: Text(mealType['label']!),
                          value: mealType['value']!.isEmpty ? null : mealType['value'],
                          groupValue: filters.mealType,
                          onChanged: (value) {
                            setDialogState(() {
                              filters.mealType = value;
                            });
                          },
                          dense: true,
                        )),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Ready Time Filter
                    const Text(
                      'Waktu Memasak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...readyTimes.map((readyTime) => RadioListTile<int?>(
                          title: Text(readyTime['label']!),
                          value: readyTime['value'],
                          groupValue: filters.maxReadyTime,
                          onChanged: (value) {
                            setDialogState(() {
                              filters.maxReadyTime = value;
                            });
                          },
                          dense: true,
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      filters.clear();
                    });
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(filters);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getFilterSummary() {
    List<String> summaries = [];
    
    if (filters.diet != null) {
      final diet = diets.firstWhere((d) => d['value'] == filters.diet);
      summaries.add(diet['label']!);
    }
    
    if (filters.mealType != null) {
      final mealType = mealTypes.firstWhere((m) => m['value'] == filters.mealType);
      summaries.add(mealType['label']!);
    }
    
    if (filters.maxReadyTime != null) {
      final readyTime = readyTimes.firstWhere((r) => r['value'] == filters.maxReadyTime);
      summaries.add(readyTime['label']!);
    }
    
    return summaries.isEmpty ? 'Semua Resep' : summaries.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: InkWell(
              onTap: _showFilterDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: filters.hasAnyFilter ? Colors.orange : Colors.grey[300]!,
                    width: filters.hasAnyFilter ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: filters.hasAnyFilter ? Colors.orange[50] : Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: filters.hasAnyFilter ? Colors.orange : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFilterSummary(),
                        style: TextStyle(
                          color: filters.hasAnyFilter ? Colors.orange[800] : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: filters.hasAnyFilter ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (filters.hasAnyFilter) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Clear Filter Button
          if (filters.hasAnyFilter) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  filters.clear();
                });
                widget.onFiltersChanged(filters);
              },
              icon: const Icon(Icons.clear),
              iconSize: 20,
              tooltip: 'Hapus Filter',
            ),
          ],
        ],
      ),
    );
  }
}