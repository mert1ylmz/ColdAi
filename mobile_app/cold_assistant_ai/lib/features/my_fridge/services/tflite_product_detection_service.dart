import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/model_labels.dart';
import '../data/shelf_life_table.dart';

/// On-device hiyerarşik ürün tanıma.
///
/// 1. `ana_model_yenilenen.tflite` → meyve / paketli / sebze
/// 2. Seçilen kategorinin alt modeli → ürün adı
///
/// Backend `config.py` ile aynı sınıf sıraları, eşikler ve 224×224 / 255
/// normalize ön-işlemi kullanılır.
class TfliteProductDetectionService {
  static const int _inputSize = 224;

  static const Map<String, String> _modelAssets = {
    'main': 'assets/models/ana_model_yenilenen.tflite',
    'meyve': 'assets/models/meyve_modeli_yeni.tflite',
    'sebze': 'assets/models/sebze_modeli_yeni.tflite',
    'paketli': 'assets/models/paketli_modeli_yeni.tflite',
  };

  static final Map<String, Interpreter> _cache = {};

  Future<Interpreter> _loadModel(String key) async {
    final cached = _cache[key];
    if (cached != null) return cached;
    final interpreter = await Interpreter.fromAsset(_modelAssets[key]!);
    _cache[key] = interpreter;
    // İlk yüklemede tensor detaylarını yazdır — normalize/dtype tespiti için.
    final inT = interpreter.getInputTensors().first;
    final outT = interpreter.getOutputTensors().first;
    // ignore: avoid_print
    print('TFLITE[$key] in: shape=${inT.shape} type=${inT.type} '
        'out: shape=${outT.shape} type=${outT.type}');
    return interpreter;
  }

  Future<Map<String, dynamic>?> detectProduct(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var decoded = img.decodeImage(bytes);
      if (decoded == null) {
        // ignore: avoid_print
        print('TFLITE: image decode failed (HEIC?) — bytes=${bytes.length}');
        return {'label': 'Bilinmiyor', 'confidence': 0.0};
      }
      // iPhone fotoğrafları EXIF rotation taşır; piksel buffer'ına uygula.
      decoded = img.bakeOrientation(decoded);
      // ignore: avoid_print
      print('TFLITE: image ${decoded.width}x${decoded.height}');

      final input = _preprocess(decoded);

      // 1) Ana model
      final mainProbs = await _runModel('main', input, ModelLabels.mainCategories.length);
      // ignore: avoid_print
      print('TFLITE main probs: '
          '${[for (var i = 0; i < mainProbs.length; i++) "${ModelLabels.mainCategories[i]}=${mainProbs[i].toStringAsFixed(3)}"].join(", ")}');
      final mainTop = _topK(mainProbs, 2);
      final mainBestIdx = mainTop[0].$1;
      final mainBestProb = mainTop[0].$2;
      final mainGap = mainBestProb - mainTop[1].$2;

      if (mainBestProb < ModelLabels.mainThreshold || mainGap < ModelLabels.top2GapThreshold) {
        // ignore: avoid_print
        print('TFLITE main rejected: best=${mainBestProb.toStringAsFixed(3)} gap=${mainGap.toStringAsFixed(3)}');
        return {'label': 'Bilinmiyor', 'confidence': mainBestProb};
      }

      final category = ModelLabels.mainCategories[mainBestIdx];

      // 2) Alt model
      final subLabels = ModelLabels.subClasses[category]!;
      final subProbs = await _runModel(category, input, subLabels.length);
      // ignore: avoid_print
      print('TFLITE sub[$category] top3: '
          '${_topK(subProbs, 3).map((e) => "${subLabels[e.$1]}=${e.$2.toStringAsFixed(3)}").join(", ")}');
      final subTop = _topK(subProbs, 2);
      final subBestIdx = subTop[0].$1;
      final subBestProb = subTop[0].$2;
      final subGap = subBestProb - subTop[1].$2;

      if (subBestProb < ModelLabels.subThreshold || subGap < ModelLabels.top2GapThreshold) {
        // ignore: avoid_print
        print('TFLITE sub rejected: best=${subBestProb.toStringAsFixed(3)} gap=${subGap.toStringAsFixed(3)}');
        return {'label': 'Bilinmiyor', 'confidence': subBestProb};
      }

      final enLabel = subLabels[subBestIdx];
      final trLabel = ModelLabels.enToTr[enLabel] ?? enLabel;
      final filterKey = ModelLabels.filterKeyFor(category);

      return {
        'label': trLabel,
        'confidence': subBestProb,
        'category': filterKey,
        'expiry_days': ShelfLifeTable.defaultDaysFor(filterKey),
      };
    } catch (e, st) {
      // ignore: avoid_print
      print('TFLITE ERROR: $e\n$st');
      return {'label': 'Hata oluştu', 'confidence': 0.0, 'error': e.toString()};
    }
  }

  Future<List<double>> _runModel(String key, Float32List input, int outputSize) async {
    final interpreter = await _loadModel(key);
    final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);
    final output = List.generate(1, (_) => List<double>.filled(outputSize, 0.0));
    interpreter.run(inputTensor, output);
    return List<double>.from(output[0]);
  }

  Float32List _preprocess(img.Image src) {
    // ÖNEMLİ: Bu Keras modelleri içlerinde Rescaling(1/255) katmanı taşır.
    // Burada /255 yaparsak çift normalize olur ve model her şeyi siyah görür.
    // Ham 0-255 piksel değerleri veriyoruz; backend/config.py yorumu hatalı.
    final resized = img.copyResize(
      src,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
    final buffer = Float32List(_inputSize * _inputSize * 3);
    var i = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final p = resized.getPixel(x, y);
        buffer[i++] = p.r.toDouble();
        buffer[i++] = p.g.toDouble();
        buffer[i++] = p.b.toDouble();
      }
    }
    return buffer;
  }

  /// (index, prob) çiftlerini ilk k tanesi olarak döndürür (azalan sıra).
  List<(int, double)> _topK(List<double> probs, int k) {
    final indexed = <(int, double)>[
      for (var i = 0; i < probs.length; i++) (i, probs[i]),
    ];
    indexed.sort((a, b) => b.$2.compareTo(a.$2));
    return indexed.take(k).toList();
  }

  void dispose() {
    for (final interp in _cache.values) {
      interp.close();
    }
    _cache.clear();
  }
}
