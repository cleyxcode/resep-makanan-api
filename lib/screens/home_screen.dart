import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../widgets/search_widget.dart';
import '../widgets/filter_widget.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = []; // list untuk menyimpan resep
  bool isLoading = true; // status loading
  String errorMessage = ''; // pesan error
  String currentQuery = 'pasta'; // query pencarian saat ini
  FilterData currentFilters = FilterData(); // filter saat ini

  @override
  void initState() {
    super.initState();
    loadRecipes(); // panggil fungsi load data
  }

  // Fungsi untuk memuat data resep
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
        number: 10, // ambil 10 resep
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

      print('Berhasil memuat ${recipes.length} resep untuk "$searchQuery" dengan filter'); // debug
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error di loadRecipes: $e'); // debug
    }
  }

  // Fungsi untuk handle pencarian
  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      loadRecipes(query: query.trim());
    }
  }

  // Fungsi untuk clear pencarian
  void _onClearSearch() {
    loadRecipes(query: 'pasta'); // kembali ke default
  }

  // Fungsi untuk handle filter
  void _onFiltersChanged(FilterData filters) {
    setState(() {
      currentFilters = filters;
    });
    loadRecipes(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe App'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Widget Pencarian
          SearchWidget(
            initialQuery: currentQuery,
            onSearch: _onSearch,
            onClear: _onClearSearch,
          ),
          // Widget Filter
          FilterWidget(
            currentFilters: currentFilters,
            onFiltersChanged: _onFiltersChanged,
          ),
          // Hasil pencarian
          Expanded(
            child: buildBody(),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      // Tampilkan loading
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat resep...'),
          ],
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      // Tampilkan error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error:'),
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loadRecipes(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (recipes.isEmpty) {
      // Tidak ada data
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Tidak ada resep ditemukan untuk "$currentQuery"'),
            const SizedBox(height: 8),
            const Text(
              'Coba kata kunci lain',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      // Tampilkan data resep
      return ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return buildRecipeCard(recipe);
        },
      );
    }
  }

  Widget buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Gambar resep
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: recipe.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              const SizedBox(width: 12),
              // Informasi resep
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${recipe.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap untuk detail',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}