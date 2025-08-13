class Recipe {
  final int id;
  final String title;
  final String image;
  final String imageType;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.imageType,
  });

  // Mengubah JSON menjadi object Recipe
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tidak ada judul',
      image: json['image'] ?? '',
      imageType: json['imageType'] ?? 'jpg',
    );
  }
}

class RecipeResponse {
  final int offset;
  final int number;
  final List<Recipe> results;
  final int totalResults;

  RecipeResponse({
    required this.offset,
    required this.number,
    required this.results,
    required this.totalResults,
  });

  // Mengubah JSON response menjadi object RecipeResponse
  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    return RecipeResponse(
      offset: json['offset'] ?? 0,
      number: json['number'] ?? 0,
      results: (json['results'] as List)
          .map((recipeJson) => Recipe.fromJson(recipeJson))
          .toList(),
      totalResults: json['totalResults'] ?? 0,
    );
  }
}