import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide Language;

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ai_constants.dart';
import '../../../core/services/database_service.dart';
import '../../recipes/models/recipe_model.dart';

class SmartSuggestionPage extends StatefulWidget {
  final Language lang;

  const SmartSuggestionPage({super.key, required this.lang});

  @override
  State<SmartSuggestionPage> createState() => _SmartSuggestionPageState();
}

class _SmartSuggestionPageState extends State<SmartSuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMsg> _messages = [];
  bool _isTyping = false;

  GenerativeModel? _model;
  ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    _initAI();

    _messages.add(_ChatMsg(
      text: widget.lang == Language.tr
          ? "Merhaba! Dolabındaki ürünlere göre sana önerilerde bulunabilirim. Sorunu sor!"
          : "Hello! I can give you suggestions based on your fridge items. Ask away!",
      isUser: false,
    ));
  }

  void _initAI() {
    if (AIConstants.geminiApiKey.isNotEmpty) {
      final systemPrompt = widget.lang == Language.tr
          ? 'Sen bir akıllı mutfak asistanısın. Kullanıcının buzdolabındaki malzemelere göre tarif önerilerinde bulunuyorsun.\n\n'
              'Tarif verdiğinde, MUTLAKA aşağıdaki formatı kullan:\n\n'
              '[TARIF_ADI]Tarifin adı[/TARIF_ADI]\n'
              '[MALZEMELER]\n- Malzeme 1\n- Malzeme 2\n[/MALZEMELER]\n'
              '[HAZIRLANISI]\nAdım adım hazırlanış.\n[/HAZIRLANISI]\n'
              '[SURE]Dakika cinsinden süre, sadece sayı[/SURE]\n'
              '[ZORLUK]Kolay veya Orta veya Zor[/ZORLUK]\n\n'
              'Tarif dışı sorularda normal yanıt ver.'
          : 'You are a smart kitchen assistant. Provide recipes based on fridge ingredients.\n\n'
              'Format:\n[TARIF_ADI]Name[/TARIF_ADI]\n[MALZEMELER]\n- Item\n[/MALZEMELER]\n'
              '[HAZIRLANISI]\nSteps\n[/HAZIRLANISI]\n[SURE]Minutes[/SURE]\n[ZORLUK]Easy/Medium/Hard[/ZORLUK]';

      _model = GenerativeModel(
        model: AIConstants.geminiModel,
        apiKey: AIConstants.geminiApiKey,
        systemInstruction: Content.text(systemPrompt),
      );
      _chatSession = _model!.startChat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static final _titleTag =
      RegExp(r'\[TARIF_ADI\](.*?)\[/TARIF_ADI\]', dotAll: true);
  static final _ingredientsTag =
      RegExp(r'\[MALZEMELER\](.*?)\[/MALZEMELER\]', dotAll: true);
  static final _instructionsTag =
      RegExp(r'\[HAZIRLANISI\](.*?)\[/HAZIRLANISI\]', dotAll: true);
  static final _timeTag =
      RegExp(r'\[SURE\](.*?)\[/SURE\]', dotAll: true);
  static final _difficultyTag =
      RegExp(r'\[ZORLUK\](.*?)\[/ZORLUK\]', dotAll: true);

  bool _hasRecipeTags(String text) => _titleTag.hasMatch(text);

  String _formatRecipeForDisplay(String text) {
    if (!_hasRecipeTags(text)) return text;

    final title = _titleTag.firstMatch(text)?.group(1)?.trim() ?? '';
    final ingredientsRaw =
        _ingredientsTag.firstMatch(text)?.group(1)?.trim() ?? '';
    final instructions =
        _instructionsTag.firstMatch(text)?.group(1)?.trim() ?? '';
    final time = _timeTag.firstMatch(text)?.group(1)?.trim() ?? '';
    final difficulty = _difficultyTag.firstMatch(text)?.group(1)?.trim() ?? '';

    final buf = StringBuffer();
    if (title.isNotEmpty) buf.writeln('🍳 $title\n');
    if (ingredientsRaw.isNotEmpty) {
      buf.writeln(
          widget.lang == Language.tr ? '📝 Malzemeler:' : '📝 Ingredients:');
      buf.writeln('$ingredientsRaw\n');
    }
    if (instructions.isNotEmpty) {
      buf.writeln(
          widget.lang == Language.tr ? '👨‍🍳 Hazırlanışı:' : '👨‍🍳 Instructions:');
      buf.writeln('$instructions\n');
    }
    if (time.isNotEmpty) {
      buf.writeln(
          '⏱ ${widget.lang == Language.tr ? "Süre" : "Time"}: $time dk');
    }
    if (difficulty.isNotEmpty) {
      buf.writeln(
          '📊 ${widget.lang == Language.tr ? "Zorluk" : "Difficulty"}: $difficulty');
    }

    return buf.toString().trim();
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(text: userText, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    if (_chatSession == null) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMsg(
          text: AppTexts.of("assistant_api_missing", widget.lang),
          isUser: false,
        ));
      });
      return;
    }

    try {
      final fridgeItems = await DatabaseService().getItems();
      final itemsString = fridgeItems.map((e) => e.name).join(", ");

      final promptWithContext = widget.lang == Language.tr
          ? "Buzdolabımdaki ürünler: $itemsString. Sorum şu: $userText"
          : "Items in my fridge: $itemsString. My question: $userText";

      final response =
          await _chatSession!.sendMessage(Content.text(promptWithContext));
      final replyText = response.text ?? "...";

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMsg(text: replyText, isUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMsg(text: "Hata: $e", isUser: false));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppTexts.of("smart_suggestion_page_title", widget.lang)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppTexts.of("smart_suggestion_page_subtitle", widget.lang),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: _buildAssistantSection(widget.lang),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAssistantSection(Language lang) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator(lang);
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          const Divider(height: 24),
          _buildChatInput(lang),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMsg message) {
    final bool isRecipe = !message.isUser && _hasRecipeTags(message.text);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  message.isUser ? AppColors.primary : AppColors.fieldFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.isUser
                  ? message.text
                  : _formatRecipeForDisplay(message.text),
              style: TextStyle(
                  color:
                      message.isUser ? Colors.white : AppColors.text),
            ),
          ),
          if (isRecipe)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showSaveRecipeSheet(message.text),
                icon: const Icon(Icons.bookmark_border, size: 18),
                label: Text(AppTexts.of("recipe_save_btn", widget.lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSaveRecipeSheet(String aiText) {
    final String title =
        _titleTag.firstMatch(aiText)?.group(1)?.trim() ?? 'Yeni Tarif';
    final String ingredientsRaw =
        _ingredientsTag.firstMatch(aiText)?.group(1)?.trim() ?? '';
    final List<String> ingredients = ingredientsRaw
        .split('\n')
        .map((e) => e.replaceAll('-', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final String instructions =
        _instructionsTag.firstMatch(aiText)?.group(1)?.trim() ?? '';
    final int time =
        int.tryParse(_timeTag.firstMatch(aiText)?.group(1) ?? '20') ?? 20;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecipeSaveSheet(
        lang: widget.lang,
        initialTitle: title,
        initialIngredients: ingredients,
        initialDescription: instructions,
        initialPrepMinutes: time,
        onSave: (RecipeModel recipe) async {
          await DatabaseService().insertRecipe(recipe);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    AppTexts.of("recipe_added_success", widget.lang)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildChatInput(Language lang) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: AppTexts.of(
                  "smart_suggestion_assistant_hint", lang),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(Language lang) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppTexts.of("assistant_typing", lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg({required this.text, required this.isUser});
}

class _RecipeSaveSheet extends StatefulWidget {
  final Language lang;
  final String initialTitle;
  final List<String> initialIngredients;
  final String initialDescription;
  final int initialPrepMinutes;
  final Future<void> Function(RecipeModel) onSave;

  const _RecipeSaveSheet({
    super.key,
    required this.lang,
    required this.initialTitle,
    required this.initialIngredients,
    required this.initialDescription,
    this.initialPrepMinutes = 20,
    required this.onSave,
  });

  @override
  State<_RecipeSaveSheet> createState() => _RecipeSaveSheetState();
}

class _RecipeSaveSheetState extends State<_RecipeSaveSheet> {
  late TextEditingController _titleController;
  late TextEditingController _ingController;
  late TextEditingController _descController;
  late TextEditingController _prepMinutesController;
  late String _selectedDifficulty;
  late IconData _selectedIcon;
  late List<Color> _selectedGradient;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.egg_rounded,
    Icons.soup_kitchen_rounded,
    Icons.dinner_dining_rounded,
    Icons.set_meal_rounded,
    Icons.eco_rounded,
    Icons.fastfood_rounded,
    Icons.breakfast_dining_rounded,
    Icons.rice_bowl_rounded,
    Icons.blender_rounded,
  ];

  final List<List<Color>> _availableGradients = [
    [const Color(0xFF667eea), const Color(0xFF764ba2)],
    [const Color(0xFFEF4444), const Color(0xFFF97316)],
    [const Color(0xFFF59E0B), const Color(0xFFEAB308)],
    [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    [const Color(0xFF10B981), const Color(0xFF059669)],
    [const Color(0xFF22C55E), const Color(0xFF84CC16)],
    [const Color(0xFFF97316), const Color(0xFFFBBF24)],
    [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
    [const Color(0xFFE11D48), const Color(0xFFBE185D)],
    [const Color(0xFFEC4899), const Color(0xFFF472B6)],
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _ingController = TextEditingController(
      text: widget.initialIngredients.join(', '),
    );
    _descController = TextEditingController(text: widget.initialDescription);
    _prepMinutesController =
        TextEditingController(text: widget.initialPrepMinutes.toString());
    _selectedDifficulty = 'recipe_easy';
    _selectedIcon = Icons.restaurant;
    _selectedGradient = _availableGradients[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingController.dispose();
    _descController.dispose();
    _prepMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppTexts.of("recipe_name", widget.lang),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ingController,
              decoration: InputDecoration(
                labelText: AppTexts.of("recipe_ingredients", widget.lang),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppTexts.of("recipe_desc", widget.lang),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prepMinutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppTexts.of("recipe_prep_time_label", widget.lang),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              items: ['recipe_easy', 'recipe_medium', 'recipe_hard']
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(AppTexts.of(d, widget.lang)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDifficulty = value);
                }
              },
              decoration: InputDecoration(
                labelText:
                    AppTexts.of("recipe_difficulty_label", widget.lang),
              ),
            ),
            const SizedBox(height: 12),
            Text(AppTexts.of("product", widget.lang),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = _availableIcons[index];
                        _selectedGradient = _availableGradients[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _availableGradients[index],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedIcon == _availableIcons[index]
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _availableIcons[index],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final recipe = RecipeModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nameKey: _titleController.text,
                  descKey: _descController.text,
                  ingredients: _ingController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  prepMinutes:
                      int.tryParse(_prepMinutesController.text) ?? 20,
                  difficultyKey: _selectedDifficulty,
                  icon: _selectedIcon,
                  gradientColors: _selectedGradient,
                );
                await widget.onSave(recipe);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(AppTexts.of("recipe_save_btn", widget.lang)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}