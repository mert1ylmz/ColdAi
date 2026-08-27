import 'package:flutter/material.dart';

class RecipeModel {
  final String? id;
  final String nameKey;
  final String descKey;
  final List<String> ingredients;
  final int prepMinutes;
  final String difficultyKey;
  final IconData icon;
  final List<Color> gradientColors;

  const RecipeModel({
    this.id,
    required this.nameKey,
    required this.descKey,
    required this.ingredients,
    required this.prepMinutes,
    required this.difficultyKey,
    required this.icon,
    required this.gradientColors,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameKey,
      'description': descKey,
      'ingredients': ingredients.join(','),
      'prepMinutes': prepMinutes,
      'difficulty': difficultyKey,
      'iconCode': icon.codePoint,
      'gradientColors': gradientColors.map((c) => c.value.toString()).join(','),
    };
  }

  static IconData _iconFromCode(int code) {
    const knownIcons = <int, IconData>{
      0xe56c: Icons.restaurant,
      0xe532: Icons.local_dining,
      0xe25a: Icons.fastfood,
      0xe57a: Icons.set_meal,
      0xe53d: Icons.lunch_dining,
      0xe539: Icons.breakfast_dining,
      0xe53a: Icons.dinner_dining,
      0xe001: Icons.cake,
      0xf052: Icons.emoji_food_beverage,
      0xe1bc: Icons.coffee,
    };
    return knownIcons[code] ?? Icons.restaurant;
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    final ingredientsStr = map['ingredients'] as String? ?? '';
    final colorsStr = map['gradientColors'] as String? ?? '';
    return RecipeModel(
      id: map['id'] as String?,
      nameKey: map['name'] as String? ?? '',
      descKey: map['description'] as String? ?? '',
      ingredients: ingredientsStr.isNotEmpty ? ingredientsStr.split(',') : [],
      prepMinutes: map['prepMinutes'] as int? ?? 0,
      difficultyKey: map['difficulty'] as String? ?? 'recipe_easy',
      icon: _iconFromCode(map['iconCode'] as int? ?? Icons.restaurant.codePoint),
      gradientColors: colorsStr.isNotEmpty
          ? colorsStr.split(',').map((s) => Color(int.parse(s))).toList()
          : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
    );
  }
}
