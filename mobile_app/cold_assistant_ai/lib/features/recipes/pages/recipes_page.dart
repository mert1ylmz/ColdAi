import 'package:flutter/material.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/database_service.dart';
import '../models/recipe_model.dart';

class RecipesPage extends StatefulWidget {
  final Language lang;

  const RecipesPage({super.key, required this.lang});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<RecipeModel> _customRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomRecipes();
  }

  Future<void> _loadCustomRecipes() async {
    try {
      final recipes = await DatabaseService().getRecipes();
      if (mounted) {
        setState(() {
          _customRecipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRecipe(String id) async {
    await DatabaseService().deleteRecipe(id);
    _loadCustomRecipes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.of("recipe_deleted", widget.lang)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static final List<RecipeModel> _staticRecipes = [
    RecipeModel(
      nameKey: "recipe_1_name",
      descKey: "recipe_1_desc",
      ingredients: ["Domates", "Biber", "Yumurta", "Zeytinyağı", "Tuz"],
      prepMinutes: 15,
      difficultyKey: "recipe_easy",
      icon: Icons.egg_rounded,
      gradientColors: [const Color(0xFFEF4444), const Color(0xFFF97316)],
    ),
    RecipeModel(
      nameKey: "recipe_2_name",
      descKey: "recipe_2_desc",
      ingredients: ["Kırmızı Mercimek", "Soğan", "Havuç", "Patates", "Tereyağı"],
      prepMinutes: 30,
      difficultyKey: "recipe_easy",
      icon: Icons.soup_kitchen_rounded,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
    ),
    RecipeModel(
      nameKey: "recipe_3_name",
      descKey: "recipe_3_desc",
      ingredients: ["Makarna", "Kıyma", "Domates Sosu", "Soğan", "Sarımsak"],
      prepMinutes: 35,
      difficultyKey: "recipe_medium",
      icon: Icons.dinner_dining_rounded,
      gradientColors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    ),
    RecipeModel(
      nameKey: "recipe_4_name",
      descKey: "recipe_4_desc",
      ingredients: ["Tavuk Göğüs", "Biber", "Domates", "Soğan", "Baharatlar"],
      prepMinutes: 40,
      difficultyKey: "recipe_medium",
      icon: Icons.set_meal_rounded,
      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
    RecipeModel(
      nameKey: "recipe_5_name",
      descKey: "recipe_5_desc",
      ingredients: ["Domates", "Salatalık", "Biber", "Soğan", "Zeytinyağı"],
      prepMinutes: 10,
      difficultyKey: "recipe_easy",
      icon: Icons.eco_rounded,
      gradientColors: [const Color(0xFF22C55E), const Color(0xFF84CC16)],
    ),
    RecipeModel(
      nameKey: "recipe_6_name",
      descKey: "recipe_6_desc",
      ingredients: ["Patates", "Ayçiçek Yağı", "Tuz"],
      prepMinutes: 20,
      difficultyKey: "recipe_easy",
      icon: Icons.fastfood_rounded,
      gradientColors: [const Color(0xFFF97316), const Color(0xFFFBBF24)],
    ),
    RecipeModel(
      nameKey: "recipe_7_name",
      descKey: "recipe_7_desc",
      ingredients: ["Yumurta", "Peynir", "Biber", "Domates", "Tereyağı"],
      prepMinutes: 10,
      difficultyKey: "recipe_easy",
      icon: Icons.breakfast_dining_rounded,
      gradientColors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
    ),
    RecipeModel(
      nameKey: "recipe_8_name",
      descKey: "recipe_8_desc",
      ingredients: ["Pirinç", "Tereyağı", "Su", "Tuz"],
      prepMinutes: 25,
      difficultyKey: "recipe_easy",
      icon: Icons.rice_bowl_rounded,
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
    ),
    RecipeModel(
      nameKey: "recipe_9_name",
      descKey: "recipe_9_desc",
      ingredients: ["Patlıcan", "Kıyma", "Domates", "Biber", "Soğan"],
      prepMinutes: 50,
      difficultyKey: "recipe_hard",
      icon: Icons.restaurant_rounded,
      gradientColors: [const Color(0xFFE11D48), const Color(0xFFBE185D)],
    ),
    RecipeModel(
      nameKey: "recipe_10_name",
      descKey: "recipe_10_desc",
      ingredients: ["Muz", "Çilek", "Yoğurt", "Bal", "Granola"],
      prepMinutes: 5,
      difficultyKey: "recipe_easy",
      icon: Icons.blender_rounded,
      gradientColors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final allRecipes = [..._customRecipes, ..._staticRecipes];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFEFF6FF),
          ],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    AppTexts.of("recipes_title", lang),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTexts.of("recipes_subtitle", lang),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...allRecipes.map(
                    (recipe) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RecipeCard(
                        recipe: recipe,
                        lang: lang,
                        onDelete: recipe.id != null
                            ? () => _deleteRecipe(recipe.id!)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RecipeCard extends StatefulWidget {
  final RecipeModel recipe;
  final Language lang;
  final VoidCallback? onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.lang,
    this.onDelete,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final lang = widget.lang;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _expanded ? AppColors.primary.withOpacity(0.2) : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _expanded
                  ? AppColors.primary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _expanded ? 30 : 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: recipe.gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: recipe.gradientColors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(recipe.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTexts.of(recipe.nameKey, lang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTexts.of(recipe.descKey, lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null) ...[
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                ],
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildChip(
                  Icons.schedule_rounded,
                  '${recipe.prepMinutes} ${AppTexts.of("recipe_minutes", lang)}',
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildChip(
                  Icons.signal_cellular_alt_rounded,
                  AppTexts.of(recipe.difficultyKey, lang),
                  recipe.difficultyKey == "recipe_hard"
                      ? AppColors.error
                      : recipe.difficultyKey == "recipe_medium"
                          ? AppColors.warning
                          : AppColors.success,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(recipe, lang),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(RecipeModel recipe, Language lang) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: AppColors.border.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppTexts.of("recipe_ingredients", lang),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.ingredients
                .map((ingredient) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fieldFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        ingredient,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showInstructionsModal(context, recipe, lang),
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(
                lang == Language.tr ? "Hazırlanışı Göster" : "Show Instructions",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: recipe.gradientColors.first,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructionsModal(
    BuildContext context,
    RecipeModel recipe,
    Language lang,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: recipe.gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: recipe.gradientColors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(recipe.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                AppTexts.of(recipe.nameKey, lang),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                lang == Language.tr ? "HAZIRLANIŞI" : "INSTRUCTIONS",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  recipe.descKey.isNotEmpty
                      ? AppTexts.of(recipe.descKey, lang)
                      : "Hazırlanış bilgisi yok",
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppTexts.of("cancel", lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
