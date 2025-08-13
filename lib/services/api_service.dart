import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  // API Key Anda
  static const String apiKey = '0061cde1f0184bc0b610d2bfdc9e0412';
  static const String baseUrl = 'https://api.spoonacular.com';

  // Fungsi untuk search resep
  static Future<RecipeResponse> searchRecipes({
    String query = 'pasta', // default search
    int number = 10, // jumlah hasil
  }) async {
    try {
      // URL endpoint
      final url = Uri.parse(
          '$baseUrl/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number');

      print('Memanggil API: $url'); // untuk debug

      // Panggil API
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}'); // untuk debug
      print('Response Body: ${response.body}'); // untuk debug

      if (response.statusCode == 200) {
        // Berhasil
        final jsonData = json.decode(response.body);
        return RecipeResponse.fromJson(jsonData);
      } else {
        // Gagal
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // untuk debug
      throw Exception('Error: $e');
    }
  }
}