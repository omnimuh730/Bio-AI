import 'package:dio/dio.dart';
import 'package:bio_ai/core/config.dart';

import 'capture_models.dart';

class FoodSearchService {
  final Dio _dio;

  FoodSearchService([Dio? dio]) : _dio = dio ?? Dio();

  final List<FoodItem> catalog = [
    FoodItem(
      name: 'Ribeye Steak',
      desc: 'Grilled steak',
      cals: 700,
      protein: 62,
      fat: 48,
      image:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Blueberry Protein Bar',
      desc: 'Packaged Snack - 220 kcal',
      cals: 220,
      protein: 12,
      fat: 9,
      image:
          'https://images.unsplash.com/photo-1543339318-b43dc53e19e6?auto=format&fit=crop&w=150&q=80',
    ),
    FoodItem(
      name: 'Avocado Toast',
      desc: 'Breakfast - 320 kcal',
      cals: 320,
      protein: 8,
      fat: 20,
      image:
          'https://images.unsplash.com/photo-1551183053-1a9c2f2c4d04?auto=format&fit=crop&w=150&q=80',
    ),
  ];

  Future<List<FoodItem>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return List<FoodItem>.from(catalog);

    try {
      if (fatSecretAccessToken.isNotEmpty) {
        return await _searchFatSecret(q);
      }

      final response = await _dio.get(
        'https://www.themealdb.com/api/json/v1/1/search.php',
        queryParameters: {'s': q},
      );
      final data = response.data as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>?;
      if (meals == null) {
        final first = q[0].toLowerCase();
        final resp = await _dio.get(
          'https://www.themealdb.com/api/json/v1/1/search.php',
          queryParameters: {'f': first},
        );
        final data2 = resp.data as Map<String, dynamic>;
        final meals2 = data2['meals'] as List<dynamic>?;
        if (meals2 != null && meals2.isNotEmpty) {
          final candidates = meals2.cast<Map<String, dynamic>>();
          final mapped = candidates
              .where(
                (meal) =>
                    _matchesByFuzzyWords(meal['strMeal'] as String? ?? '', q),
              )
              .map(
                (meal) => FoodItem(
                  name: meal['strMeal'] as String? ?? '',
                  desc: [
                    if ((meal['strCategory'] as String?)?.isNotEmpty ?? false)
                      meal['strCategory'] as String,
                    if ((meal['strArea'] as String?)?.isNotEmpty ?? false)
                      meal['strArea'] as String,
                  ].join(' • '),
                  cals: 0,
                  protein: 0,
                  fat: 0,
                  image: meal['strMealThumb'] as String? ?? '',
                  metadata: {'rawMeal': meal},
                ),
              )
              .toList();
          if (mapped.isNotEmpty) return mapped;
        }

        return _fuzzyLocalMatches(q);
      }

      final mapped = meals.cast<Map<String, dynamic>>().map((meal) {
        return FoodItem(
          name: meal['strMeal'] as String? ?? '',
          desc: [
            if ((meal['strCategory'] as String?)?.isNotEmpty ?? false)
              meal['strCategory'] as String,
            if ((meal['strArea'] as String?)?.isNotEmpty ?? false)
              meal['strArea'] as String,
          ].join(' • '),
          cals: 0,
          protein: 0,
          fat: 0,
          image: meal['strMealThumb'] as String? ?? '',
          metadata: {'rawMeal': meal},
        );
      }).toList();

      return mapped;
    } catch (e) {
      return _fuzzyLocalMatches(q);
    }
  }

  bool _matchesByFuzzyWords(String name, String query) {
    final words = name.toLowerCase().split(RegExp(r'\s+'));
    final q = query.toLowerCase();
    for (final w in words) {
      if (w.isEmpty) continue;
      final d = _levenshtein(w, q);
      if (d <= 1 || d <= (w.length * 0.2).ceil()) return true;
    }
    return false;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);
    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  List<FoodItem> _fuzzyLocalMatches(String query) {
    final q = query.toLowerCase();
    final results = <FoodItem>[];
    for (final item in catalog) {
      final nameLower = item.name.toLowerCase();
      if (nameLower.contains(q)) {
        results.add(item);
        continue;
      }
      final words = nameLower.split(RegExp(r'\s+'));
      for (final w in words) {
        if (w.isEmpty) continue;
        final dist = _levenshtein(w, q);
        final sortedW = (w.split('')..sort()).join();
        final sortedQ = (q.split('')..sort()).join();
        if (dist <= 1 ||
            dist <= (w.length * 0.2).ceil() ||
            sortedW == sortedQ) {
          results.add(item);
          break;
        }
      }
    }
    return results;
  }

  Future<List<FoodItem>> _searchFatSecret(String query) async {
    if (fatSecretAccessToken.isEmpty) return [];
    try {
      final resp = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'foods.search',
          'search_expression': query,
          'format': 'json',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final data = resp.data as Map<String, dynamic>;
      final foods = data['foods'] != null
          ? data['foods']['food'] as List<dynamic>?
          : null;
      if (foods == null || foods.isEmpty) return [];
      final mapped = foods.cast<Map<String, dynamic>>().map((food) {
        final name =
            food['food_name'] as String? ?? food['name'] as String? ?? '';
        final foodId =
            food['food_id']?.toString() ?? food['id']?.toString() ?? '';
        final desc = food['food_type'] ?? '';
        return FoodItem(
          name: name,
          desc: desc,
          cals: 0,
          protein: 0,
          fat: 0,
          image: '',
          metadata: {
            'fatsecret_food': {'food_id': foodId, 'raw': food},
          },
        );
      }).toList();
      return mapped;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchFatSecretByName(String name) async {
    if (fatSecretAccessToken.isEmpty) return null;
    try {
      final resp = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'foods.search',
          'search_expression': name,
          'format': 'json',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final data = resp.data as Map<String, dynamic>;
      final foods = data['foods'] != null
          ? data['foods']['food'] as List<dynamic>?
          : null;
      final first = foods != null && foods.isNotEmpty
          ? foods.first as Map<String, dynamic>
          : null;
      final foodId = first != null
          ? (first['food_id']?.toString() ?? first['id']?.toString())
          : null;
      if (foodId == null) return null;
      final det = await _dio.get(
        'https://platform.fatsecret.com/rest/server.api',
        queryParameters: {
          'method': 'food.get.v4',
          'food_id': foodId,
          'format': 'json',
          'include_food_attributes': 'true',
          'flag_default_serving': 'true',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $fatSecretAccessToken'},
        ),
      );
      final detData = det.data as Map<String, dynamic>;
      return detData['food'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
