import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../widgets/search_widget.dart';
import '../widgets/filter_widget.dart';
import '../widgets/favorite_button.dart';
import 'recipe_detail_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String errorMessage = '';
  String currentQuery = '';
  FilterData currentFilters = FilterData();

  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));
    
    loadRecipes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> loadRecipes({String? query, FilterData? filters}) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final searchQuery = query ?? currentQuery;
      final searchFilters = filters ?? currentFilters;

      final response = await ApiService.searchRecipes(
        query: searchQuery,
        number: 10,
        diet: searchFilters.diet,
        type: searchFilters.mealType,
        maxReadyTime: searchFilters.maxReadyTime,
      );

      setState(() {
        recipes = response.results;
        isLoading = false;
        currentQuery = searchQuery;
        currentFilters = searchFilters;
      });

      // Start animations
      _fadeController.forward();
      _listController.forward();

      print('Berhasil memuat ${recipes.length} resep untuk "$searchQuery" dengan filter');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      _fadeController.reset();
      _listController.reset();
      loadRecipes(query: query.trim());
    }
  }

  void _onClearSearch() {
    _fadeController.reset();
    _listController.reset();
    loadRecipes(query: 'pasta');
  }

  void _onFiltersChanged(FilterData filters) {
    setState(() {
      currentFilters = filters;
    });
    _fadeController.reset();
    _listController.reset();
    loadRecipes(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Poppins',
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade600,
                Colors.orange.shade500,
                Colors.orange.shade600,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const FavoriteScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: Stack(
                children: [
                  const Icon(Icons.favorite_rounded, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: AnimatedBuilder(
                      animation: FavoriteService(),
                      builder: (context, child) {
                        final count = FavoriteService().favoriteCount;
                        if (count == 0) return const SizedBox.shrink();
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.shade300,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              tooltip: 'Favorite Recipes',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
              Colors.orange,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Section with Animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        SearchWidget(
                          initialQuery: currentQuery,
                          onSearch: _onSearch,
                          onClear: _onClearSearch,
                        ),
                        FilterWidget(
                          currentFilters: currentFilters,
                          onFiltersChanged: _onFiltersChanged,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.shade600,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: const Text(
                    'Loading delicious recipes...',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade200,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade500,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops, something went wrong!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => loadRecipes(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.orange.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey.shade500,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes found for "$currentQuery"',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different keyword or adjust filters',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: buildRecipeCard(recipes[index], index),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }

  Widget buildRecipeCard(Recipe recipe, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    RecipeDetailScreen(recipe: recipe),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.orange,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar resep
                  Hero(
                    tag: 'recipe-image-${recipe.id}',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade200,
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: recipe.image.isNotEmpty
                            ? Image.network(
                                recipe.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return buildImagePlaceholder();
                                },
                              )
                            : buildImagePlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informasi resep
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${recipe.readyInMinutes ?? 'N/A'} min',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap for details',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Favorite Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade100,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: FavoriteButton(
                      recipe: recipe,
                      size: 24,
                      activeColor: Colors.red.shade500,
                      inactiveColor: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade200,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 40,
              color: Colors.orange.shade500,
            ),
            const SizedBox(height: 4),
            Text(
              'Recipe',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}