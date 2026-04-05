import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _model;
  ChatSession? _chat;

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    _chat = _model?.startChat(history: []);
    debugPrint("AI Service initialized");
  }

  Future<String> askQuestion(String prompt) async {
    if (_chat == null) {
      // Sizin sağladığınız özel yetkili Vertex/GenAI Anahtarı:
      initialize(const String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_API_KEY_HERE'));
    }
    
    try {
      final response = await _chat!.sendMessage(Content.text(prompt));
      return response.text ?? 'Üzgünüm, cevap üretemedim.';
    } catch (e) {
      debugPrint("GenAI Error: $e");
      return 'Bir hata oluştu: $e';
    }
  }
}
