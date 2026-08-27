import 'dart:io' show Platform;

class AIConstants {
  // TODO: API anahtarını .env dosyasından yükle. Anahtarı asla kaynak kodda açık tutma.
  // Bunun yerine flutter_dotenv veya benzer bir kütüphane kullan.
  static const String geminiApiKey = 'AIzaSyAc9XrlsEyixvB4u41A4SN59TL81CGA0-8';
  static const String geminiModel = 'gemini-2.5-flash';

  /// ColdAI FastAPI backend (EfficientNetV2B0 tek geçiş inference).
  /// Android emulator host loopback'ini (10.0.2.2) otomatik seçer;
  /// gerçek cihazdan test ederken bilgisayarın LAN IP'sini kullanın.
  static String get backendBaseUrl {
    const override = String.fromEnvironment('COLDAI_BACKEND_URL');
    if (override.isNotEmpty) return override;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }
}
