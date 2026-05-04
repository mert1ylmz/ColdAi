import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_texts.dart';
import '../../../core/localization/language.dart';
import '../services/detected_product_mapper.dart';
import '../services/product_detection_service.dart';
import 'detected_product_edit_page.dart';

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

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
      _result = null;
      _errorMessage = null;
    });

    final service = ProductDetectionService();
    final result = await service.detectProduct(_image!);

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

    final lang = widget.lang;

    final detectedProduct = mapDetectionToProduct(
      label: _result!['label'],
      lang: lang,
    );

    final fridgeItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetectedProductEditPage(
          lang: lang,
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
      backgroundColor: const Color(0xFFFDF6FF),
      appBar: AppBar(
        title: Text(AppTexts.of("scan_product", lang)),
        backgroundColor: const Color(0xFFFDF6FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_image!, height: 220, fit: BoxFit.contain),
              ),

            const SizedBox(height: 24),

            if (_loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(AppTexts.of("analyzing_product", lang)),
            ],

            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            if (_result != null) ...[
              Text(
                "${AppTexts.of("product", lang)}: ${_result!['label']}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${AppTexts.of("confidence", lang)}: ${((_result!['confidence'] ?? 0) * 100).toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _openEditPage,
                icon: const Icon(Icons.edit),
                label: Text(AppTexts.of("add_to_fridge", lang)),
              ),
            ],

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => pickImage(ImageSource.camera),
                    child: Text(AppTexts.of("camera", lang)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => pickImage(ImageSource.gallery),
                    child: Text(AppTexts.of("gallery", lang)),
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
