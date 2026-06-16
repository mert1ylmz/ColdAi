import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/theme/app_colors.dart';
import '../services/detected_product_mapper.dart';
import '../services/prediction_api_service.dart';
import '../services/product_detection_service.dart';
import 'detected_product_edit_page.dart';

enum ProductEngine { gemini, backend }

const _kProductEnginePrefKey = 'product_engine';

class ScanProductPage extends StatefulWidget {
  final Language lang;

  const ScanProductPage({super.key, required this.lang});

  @override
  State<ScanProductPage> createState() => _ScanProductPageState();
}

class _ScanProductPageState extends State<ScanProductPage> {
  File? _image;
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  ProductEngine _engine = ProductEngine.gemini;

  final ImagePicker picker = ImagePicker();
  final _geminiService = ProductDetectionService();
  final _backendService = PredictionApiService();

  @override
  void initState() {
    super.initState();
    _loadEnginePref();
  }

  @override
  void dispose() {
    _backendService.dispose();
    super.dispose();
  }

  Future<void> _loadEnginePref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kProductEnginePrefKey);
    if (saved == ProductEngine.backend.name && mounted) {
      setState(() => _engine = ProductEngine.backend);
    }
  }

  Future<void> _setEngine(ProductEngine engine) async {
    setState(() => _engine = engine);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProductEnginePrefKey, engine.name);
  }

  Future<void> pickImage(ImageSource source) async {
    // maxWidth + imageQuality, iOS'ta HEIC'i otomatik JPEG'e çevirmeyi
    // tetikler (image_picker_ios davranışı) ve TFLite decode'unu garantiler.
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
      _result = null;
      _errorMessage = null;
    });

    final result = _engine == ProductEngine.gemini
        ? await _geminiService.detectProduct(_image!)
        : await _backendService.detectProduct(_image!);

    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result == null) {
        _errorMessage = AppTexts.of("api_connection_failed", widget.lang);
      } else {
        _result = result;
      }
    });
  }

  Future<void> _openEditPage() async {
    if (_result == null) return;

    final detectedProduct = mapDetectionToProduct(
      label: _result!['label'],
      lang: widget.lang,
      category: _result!['category'],
      expiryDays: _result!['expiry_days'] is int
          ? _result!['expiry_days']
          : int.tryParse(_result!['expiry_days']?.toString() ?? '7') ?? 7,
    );

    final fridgeItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetectedProductEditPage(
          lang: widget.lang,
          detectedProduct: detectedProduct,
        ),
      ),
    );

    if (!mounted) return;

    if (fridgeItem != null) {
      Navigator.pop(context, fridgeItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppTexts.of("scan_product", lang),
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildEngineSelector(lang),
            const SizedBox(height: 12),
            // Image Preview or Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, size: 64, color: AppColors.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            lang == Language.tr ? "Bir fotoğraf çekin veya seçin" : "Take or select a photo",
                            style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Status Area
            if (_loading) ...[
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
              const SizedBox(height: 16),
              Text(
                AppTexts.of("analyzing_product", lang),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ] else if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ),
            ] else if (_result != null) ...[
              _buildResultCard(lang),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Language lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!['label'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
                    ),
                    Text(
                      "${AppTexts.of("confidence", lang)}: ${((_result!['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openEditPage,
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: Text(AppTexts.of("add_to_fridge", lang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSelector(Language lang) {
    return SegmentedButton<ProductEngine>(
      segments: [
        ButtonSegment(
          value: ProductEngine.gemini,
          label: Text(AppTexts.of("engine_gemini", lang)),
          icon: const Icon(Icons.cloud_outlined, size: 18),
        ),
        ButtonSegment(
          value: ProductEngine.backend,
          label: Text(AppTexts.of("engine_backend", lang)),
          icon: const Icon(Icons.dns_rounded, size: 18),
        ),
      ],
      selected: {_engine},
      onSelectionChanged: _loading
          ? null
          : (set) => _setEngine(set.first),
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Language lang) {
    return Row(
      children: [
        _buildSourceButton(
          icon: Icons.camera_alt_rounded,
          label: AppTexts.of("camera", lang),
          onTap: () => pickImage(ImageSource.camera),
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _buildSourceButton(
          icon: Icons.photo_library_rounded,
          label: AppTexts.of("gallery", lang),
          onTap: () => pickImage(ImageSource.gallery),
          color: AppColors.text,
        ),
      ],
    );
  }

  Widget _buildSourceButton({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : onTap,
          icon: Icon(icon, size: 22),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
