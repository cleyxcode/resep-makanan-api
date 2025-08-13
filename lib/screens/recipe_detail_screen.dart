import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../widgets/favorite_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  Recipe? detailedRecipe;
  bool isLoading = true;
  String errorMessage = '';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    loadRecipeDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> loadRecipeDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final details = await ApiService.getRecipeDetails(widget.recipe.id);

      setState(() {
        detailedRecipe = details;
        isLoading = false;
      });
      
      // Start animations after loading
      _fadeController.forward();
      _slideController.forward();

      print('Berhasil memuat detail resep: ${details.title}');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error loading details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.recipe.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedScale(
              scale: isLoading ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              child: FavoriteButton(
                recipe: widget.recipe,
                size: 28,
                activeColor: Colors.red.shade400,
                inactiveColor: Colors.white70,
              ),
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
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: buildBody(),
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
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange.shade600,
                    ),
                    strokeWidth: 3,
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
                    'Loading delicious details...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
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
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton.icon(
                  onPressed: loadRecipeDetails,
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
                    elevation: 4,
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
              ),
            ],
          ),
        ),
      );
    } else if (detailedRecipe == null) {
      return const Center(
        child: Text(
          'Recipe details not found',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
      );
    } else {
      return buildRecipeDetail();
    }
  }

  Widget buildRecipeDetail() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRecipeImage(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitle(),
                    const SizedBox(height: 20),
                    buildQuickInfo(),
                    const SizedBox(height: 28),
                    if (detailedRecipe!.summary != null) ...[
                      buildSummary(),
                      const SizedBox(height: 28),
                    ],
                    if (detailedRecipe!.ingredients != null &&
                        detailedRecipe!.ingredients!.isNotEmpty) ...[
                      buildIngredients(),
                      const SizedBox(height: 28),
                    ],
                    if (detailedRecipe!.instructions != null)
                      buildInstructions(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecipeImage() {
    return Hero(
      tag: 'recipe-image-${widget.recipe.id}',
      child: Container(
        width: double.infinity,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Stack(
            children: [
              detailedRecipe!.image.isNotEmpty
                  ? Image.network(
                      detailedRecipe!.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return buildImagePlaceholder();
                      },
                    )
                  : buildImagePlaceholder(),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ],
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
              size: 80,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Recipe Image',
              style: TextStyle(
                fontSize: 16,
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

  Widget buildTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    detailedRecipe!.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.orange.shade100,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: value,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: FavoriteButton(
                      recipe: widget.recipe,
                      size: 28,
                      activeColor: Colors.red.shade400,
                      inactiveColor: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildQuickInfo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                if (detailedRecipe!.readyInMinutes != null)
                  buildInfoChip(
                    Icons.timer_outlined,
                    '${detailedRecipe!.readyInMinutes} min',
                    Colors.orange.shade600,
                    Colors.orange.shade50,
                  ),
                if (detailedRecipe!.servings != null)
                  buildInfoChip(
                    Icons.restaurant_outlined,
                    '${detailedRecipe!.servings} servings',
                    Colors.green.shade600,
                    Colors.green.shade50,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInfoChip(IconData icon, String text, Color color, Color bgColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About This Recipe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade100,
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    detailedRecipe!.summary!.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildIngredients() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...detailedRecipe!.ingredients!.asMap().entries.map(
                  (entry) {
                    int index = entry.key;
                    String ingredient = entry.value;
                    
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, itemValue, child) {
                        return Transform.translate(
                          offset: Offset(20 * (1 - itemValue), 0),
                          child: Opacity(
                            opacity: itemValue,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.orange.shade100,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade50,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 20,
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInstructions() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade100,
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 32,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        detailedRecipe!.instructions!.replaceAll(RegExp(r'<[^>]*>'), ''),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}