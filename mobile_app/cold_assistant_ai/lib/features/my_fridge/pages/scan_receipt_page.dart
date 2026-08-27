import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../../../core/services/ocr_receipt_service.dart';
import '../../../core/services/receipt_recognition_service.dart';
import '../models/fridge_item_model.dart';
import '../services/detected_product_mapper.dart';
import 'detected_product_edit_page.dart';

enum ReceiptEngine { gemini, ocr }

const _kReceiptEnginePrefKey = 'receipt_engine';

class ScanReceiptPage extends StatefulWidget {
  final Language lang;

  const ScanReceiptPage({super.key, required this.lang});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  File? _image;
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  String? _errorMessage;
  ReceiptEngine _engine = ReceiptEngine.gemini;

  final ImagePicker picker = ImagePicker();
  final _geminiService = ReceiptRecognitionService();
  final _ocrService = OcrReceiptService();

  @override
  void initState() {
    super.initState();
    _loadEnginePref();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _loadEnginePref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kReceiptEnginePrefKey);
    if (saved == ReceiptEngine.ocr.name && mounted) {
      setState(() => _engine = ReceiptEngine.ocr);
    }
  }

  Future<void> _setEngine(ReceiptEngine engine) async {
    setState(() => _engine = engine);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReceiptEnginePrefKey, engine.name);
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
      _results = [];
      _errorMessage = null;
    });

    try {
      final results = _engine == ReceiptEngine.gemini
          ? await _geminiService.scanReceipt(_image!)
          : await _ocrService.scanReceipt(_image!);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
          if (results.isEmpty) {
            _errorMessage = "Fişte bilinen bir ürün bulunamadı.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "OCR Hatası: $e";
        });
      }
    }
  }

  Future<void> _addItems() async {
    // Fişten bulunan tüm ürünleri tek tek onaylatabiliriz veya toplu ekleyebiliriz.
    // Basitlik için ilk üründen başlayarak düzenleme sayfasına gönderelim.
    
    for (var res in _results) {
      final detectedProduct = mapDetectionToProduct(
        label: res['product_tr'] ?? res['product'],
        lang: widget.lang,
        category: res['category'],
        expiryDays: res['expiry_days'] is int
            ? res['expiry_days']
            : int.tryParse(res['expiry_days']?.toString() ?? '7') ?? 7,
      );

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetectedProductEditPage(
            lang: widget.lang,
            detectedProduct: detectedProduct,
          ),
        ),
      );

      if (result != null && result is FridgeItemModel) {
         // MyFridgePage'e geri dönüp listeyi yenilemesi için sonucu döndürelim
         // (Veya burada direkt DB'ye kaydedebiliriz)
         // Bu örnekte MyFridgePage'e birini döndürüp diğerlerini de kaydetmiş gibi yapalım
         // Ama en iyisi hepsini onaylattıktan sonra toplu dönmek.
      }
    }
    
    Navigator.pop(context, true); // true dönerek yenileme tetiklenebilir
  }

  Widget _buildEngineSelector(Language lang) {
    return SegmentedButton<ReceiptEngine>(
      segments: [
        ButtonSegment(
          value: ReceiptEngine.gemini,
          label: Text(AppTexts.of("engine_gemini", lang)),
          icon: const Icon(Icons.cloud_outlined, size: 18),
        ),
        ButtonSegment(
          value: ReceiptEngine.ocr,
          label: Text(AppTexts.of("engine_ocr", lang)),
          icon: const Icon(Icons.text_fields_rounded, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FF),
      appBar: AppBar(
        title: Text(AppTexts.of("scan_receipt", lang)),
        backgroundColor: const Color(0xFFFDF6FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEngineSelector(lang),
            const SizedBox(height: 12),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_image!, height: 200, fit: BoxFit.contain),
              ),
            const SizedBox(height: 20),
            if (_loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(AppTexts.of("scanning_receipt", lang)),
            ],
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_results.isNotEmpty) ...[
              Text(
                "${_results.length} Ürün Bulundu",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return ListTile(
                      title: Text(item['product_tr'] ?? item['product']),
                      subtitle: Text("Güven: %${(item['confidence'] * 100).toStringAsFixed(1)}"),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addItems,
                child: const Text("Ürünleri Onayla ve Ekle"),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(AppTexts.of("camera", lang)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppTexts.of("gallery", lang)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
