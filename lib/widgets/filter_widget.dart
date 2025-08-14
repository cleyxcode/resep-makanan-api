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

  int get activeFilterCount {
    int count = 0;
    if (diet != null) count++;
    if (mealType != null) count++;
    if (maxReadyTime != null) count++;
    return count;
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

class _FilterWidgetState extends State<FilterWidget> 
    with TickerProviderStateMixin {
  late FilterData filters;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Daftar diet options dengan icons
  final List<Map<String, dynamic>> diets = [
    {'value': null, 'label': 'Semua Diet', 'icon': Icons.restaurant_menu, 'color': Colors.grey},
    {'value': 'vegetarian', 'label': 'Vegetarian', 'icon': Icons.eco, 'color': Colors.green},
    {'value': 'vegan', 'label': 'Vegan', 'icon': Icons.nature, 'color': Colors.lightGreen},
    {'value': 'gluten free', 'label': 'Gluten Free', 'icon': Icons.no_food, 'color': Colors.amber},
    {'value': 'ketogenic', 'label': 'Keto', 'icon': Icons.fitness_center, 'color': Colors.purple},
    {'value': 'paleo', 'label': 'Paleo', 'icon': Icons.local_fire_department, 'color': Colors.deepOrange},
  ];

  // Daftar meal type options dengan icons
  final List<Map<String, dynamic>> mealTypes = [
    {'value': null, 'label': 'Semua Waktu', 'icon': Icons.schedule, 'color': Colors.grey},
    {'value': 'breakfast', 'label': 'Sarapan', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'value': 'lunch', 'label': 'Makan Siang', 'icon': Icons.wb_cloudy, 'color': Colors.blue},
    {'value': 'dinner', 'label': 'Makan Malam', 'icon': Icons.nights_stay, 'color': Colors.indigo},
    {'value': 'snack', 'label': 'Camilan', 'icon': Icons.cake, 'color': Colors.pink},
    {'value': 'dessert', 'label': 'Dessert', 'icon': Icons.icecream, 'color': Colors.cyan},
  ];

  // Daftar waktu memasak dengan icons
  final List<Map<String, dynamic>> readyTimes = [
    {'value': null, 'label': 'Semua Waktu', 'icon': Icons.all_inclusive, 'color': Colors.grey},
    {'value': 15, 'label': 'Max 15 menit', 'icon': Icons.flash_on, 'color': Colors.red},
    {'value': 30, 'label': 'Max 30 menit', 'icon': Icons.speed, 'color': Colors.orange},
    {'value': 60, 'label': 'Max 1 jam', 'icon': Icons.access_time, 'color': Colors.blue},
    {'value': 120, 'label': 'Max 2 jam', 'icon': Icons.hourglass_bottom, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    filters = widget.currentFilters.copy();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Filter Resep',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              filters.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Diet Filter
                          _buildFilterSection(
                            'Diet',
                            Icons.restaurant,
                            diets,
                            filters.diet,
                            (value) {
                              setDialogState(() {
                                filters.diet = value;
                              });
                            },
                            setDialogState,
                          ),

                          const SizedBox(height: 32),

                          // Meal Type Filter
                          _buildFilterSection(
                            'Waktu Makan',
                            Icons.schedule,
                            mealTypes,
                            filters.mealType,
                            (value) {
                              setDialogState(() {
                                filters.mealType = value;
                              });
                            },
                            setDialogState,
                          ),

                          const SizedBox(height: 32),

                          // Ready Time Filter
                          _buildTimeFilterSection(setDialogState),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFFF5722)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onFiltersChanged(filters);
                              Navigator.of(context).pop();
                              setState(() {}); // Update main widget
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFFF5722),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Terapkan Filter ${filters.activeFilterCount > 0 ? '(${filters.activeFilterCount})' : ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFilterSection(
    String title,
    IconData titleIcon,
    List<Map<String, dynamic>> options,
    String? currentValue,
    Function(String?) onChanged,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(titleIcon, color: const Color(0xFFFF5722), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option['value'];
            return GestureDetector(
              onTap: () => onChanged(option['value']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFFF5722) 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFFF5722) 
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option['icon'],
                      size: 18,
                      color: isSelected 
                          ? Colors.white 
                          : option['color'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeFilterSection(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer, color: Color(0xFFFF5722), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Waktu Memasak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: readyTimes.map((option) {
            final isSelected = filters.maxReadyTime == option['value'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setDialogState(() {
                      filters.maxReadyTime = option['value'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFFF5722).withOpacity(0.1) 
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFFFF5722) 
                            : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFFFF5722) 
                                : option['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            option['icon'],
                            size: 20,
                            color: isSelected 
                                ? Colors.white 
                                : option['color'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected 
                                  ? const Color(0xFFFF5722) 
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5722),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Main Filter Button
          Expanded(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showFilterDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: filters.hasAnyFilter 
                          ? const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                            )
                          : null,
                      color: filters.hasAnyFilter ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: filters.hasAnyFilter 
                            ? Colors.transparent 
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: filters.hasAnyFilter 
                              ? const Color(0xFFFF9800).withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: filters.hasAnyFilter ? 12 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: filters.hasAnyFilter 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: filters.hasAnyFilter 
                                ? Colors.white 
                                : const Color(0xFFFF5722),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getFilterSummary(),
                            style: TextStyle(
                              color: filters.hasAnyFilter 
                                  ? Colors.white 
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight: filters.hasAnyFilter 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (filters.hasAnyFilter) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filters.activeFilterCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Clear Filter Button
          if (filters.hasAnyFilter) ...[
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    filters.clear();
                  });
                  widget.onFiltersChanged(filters);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}