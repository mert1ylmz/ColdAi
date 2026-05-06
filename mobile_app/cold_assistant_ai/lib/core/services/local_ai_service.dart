import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/constants/ai_constants.dart';

class LocalAIService {
  static final LocalAIService _instance = LocalAIService._internal();
  factory LocalAIService() => _instance;
  LocalAIService._internal();

  Interpreter? _mainInterpreter;
  Interpreter? _fruitInterpreter;
  Interpreter? _vegetableInterpreter;
  Interpreter? _packagedInterpreter;

  bool _isLoaded = false;

  Future<void> loadModels() async {
    if (_isLoaded) return;
    
    try {
      _mainInterpreter = await Interpreter.fromAsset(AIConstants.mainModelPath);
      _fruitInterpreter = await Interpreter.fromAsset(AIConstants.fruitModelPath);
      _vegetableInterpreter = await Interpreter.fromAsset(AIConstants.vegetableModelPath);
      _packagedInterpreter = await Interpreter.fromAsset(AIConstants.packagedModelPath);
      
      _isLoaded = true;
      print("AI Models loaded successfully");
    } catch (e) {
      print("Error loading models: $e");
    }
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (!_isLoaded) await loadModels();
    if (!_isLoaded) return {"success": false, "message": "Modeller yüklenemedi"};

    try {
      // 1. Preprocessing
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return {"success": false, "message": "Görüntü çözülemedi"};

      final resizedImage = img.copyResize(
        decodedImage,
        width: AIConstants.imgSize,
        height: AIConstants.imgSize,
        interpolation: img.Interpolation.linear,
      );

      // (1, 224, 224, 3) formatında giriş hazırla
      var input = Float32List(1 * AIConstants.imgSize * AIConstants.imgSize * 3);
      var buffer = input.buffer;
      var offset = 0;
      for (var y = 0; y < AIConstants.imgSize; y++) {
        for (var x = 0; x < AIConstants.imgSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[offset++] = pixel.r / 255.0;
          input[offset++] = pixel.g / 255.0;
          input[offset++] = pixel.b / 255.0;
        }
      }

      final reshapedInput = input.reshape([1, AIConstants.imgSize, AIConstants.imgSize, 3]);

      // 2. Main Model Inference (Category Prediction)
      var mainOutput = List<double>.filled(AIConstants.mainCategories.length, 0).reshape([1, AIConstants.mainCategories.length]);
      _mainInterpreter!.run(reshapedInput, mainOutput);
      
      List<double> mainProbs = List<double>.from(mainOutput[0]);
      int categoryIdx = _getMaxIndex(mainProbs);
      double categoryConf = mainProbs[categoryIdx];
      String category = AIConstants.mainCategories[categoryIdx];

      if (categoryConf < AIConstants.mainModelThreshold) {
        return {
          "success": true,
          "category": null,
          "product": null,
          "confidence": categoryConf,
          "is_known": false,
          "message": "Kategori belirlenemedi",
        };
      }

      // 3. Sub Model Inference (Product Prediction)
      Interpreter? subInterpreter;
      if (category == 'meyve') subInterpreter = _fruitInterpreter;
      else if (category == 'sebze') subInterpreter = _vegetableInterpreter;
      else if (category == 'paketli') subInterpreter = _packagedInterpreter;

      if (subInterpreter == null) return {"success": false, "message": "Alt model bulunamadı"};

      int numClasses = AIConstants.productClasses[category]!.length;
      var subOutput = List<double>.filled(numClasses, 0).reshape([1, numClasses]);
      subInterpreter.run(reshapedInput, subOutput);

      List<double> subProbs = List<double>.from(subOutput[0]);
      int productIdx = _getMaxIndex(subProbs);
      double productConf = subProbs[productIdx];
      String productName = AIConstants.productClasses[category]![productIdx];
      String productTr = AIConstants.enToTr[productName] ?? productName;

      if (productConf < AIConstants.subModelThreshold) {
        return {
          "success": true,
          "category": category,
          "product": null,
          "confidence": productConf,
          "is_known": false,
          "message": "Ürün belirlenemedi",
        };
      }

      return {
        "success": true,
        "category": category,
        "product": productName,
        "product_tr": productTr,
        "confidence": productConf,
        "is_known": true,
      };
    } catch (e) {
      print("Prediction error: $e");
      return {"success": false, "message": "Hata: $e"};
    }
  }

  int _getMaxIndex(List<double> list) {
    int maxIdx = 0;
    double maxVal = list[0];
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  void dispose() {
    _mainInterpreter?.close();
    _fruitInterpreter?.close();
    _vegetableInterpreter?.close();
    _packagedInterpreter?.close();
  }
}
