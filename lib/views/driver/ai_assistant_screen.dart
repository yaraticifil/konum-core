import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai', 
      'text': 'Merhaba Sayın Hizmet Sağlayıcı. Ben KONUM Hukuk ve Operasyon Rehberinizim. Mevzuat, haklarınız veya sistem işleyişi hakkında size nasıl yardımcı olabilirim?'
    }
  ];
  bool _isLoading = false;

  // Aristokrat Renk Paleti
  static const Color _richBlack = Color(0xFF0A0A0A);
  static const Color _deepAnthracite = Color(0xFF121212);
  static const Color _monsieurGold = Color(0xFFD4AF37);
  static const Color _bronzeAccent = Color(0xFFCD7F32);

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final text = _controller.text.trim();
    _controller.clear();
    
    setState(() {
      _messages.insert(0, {'role': 'user', 'text': text});
      _isLoading = true;
    });

    try {
      final response = await AIService().askQuestion(text);
      if (mounted) {
        setState(() {
          _messages.insert(0, {'role': 'ai', 'text': response});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.insert(0, {'role': 'ai', 'text': 'Şu an sistem yoğunluğu nedeniyle yanıt verilemiyor. Lütfen kısa süre sonra tekrar deneyiniz.'});
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _richBlack,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'HUKUK VE OPERASYON REHBERİ', 
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900, 
                letterSpacing: 2, 
                fontSize: 14,
                color: _monsieurGold
              )
            ),
            Text(
              'YASAL DANIŞMANLIK ARABİRİMİ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 1.5
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _monsieurGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Arka Plan Gradyanı
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [_deepAnthracite, _richBlack],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
          
          Column(
            children: [
              _buildLegalDisclaimer(),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return _buildModernBubble(message['text'] ?? '', isUser);
                  },
                ),
              ),
              if (_isLoading) _buildLoadingIndicator(),
              _buildModernInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: _monsieurGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _monsieurGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _monsieurGold, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Yapay zeka yanıtları bilgilendirme amaçlıdır, resmi hukuki tavsiye yerine geçmez.',
              style: GoogleFonts.publicSans(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? _monsieurGold : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
          border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: _monsieurGold.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: _monsieurGold),
                    const SizedBox(width: 6),
                    Text(
                      'KONUM REHBERİ',
                      style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: _monsieurGold, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            Text(
              text,
              style: GoogleFonts.publicSans(
                color: isUser ? Colors.black : Colors.grey[300],
                fontSize: 13,
                height: 1.5,
                fontWeight: isUser ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(color: _monsieurGold, strokeWidth: 1.5),
          ),
          const SizedBox(width: 12),
          Text(
            'Mevzuat taranıyor...',
            style: GoogleFonts.spaceGrotesk(fontSize: 10, color: _monsieurGold, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputArea() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.publicSans(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Mevzuat veya operasyon sorunuz...',
                      hintStyle: GoogleFonts.publicSans(color: Colors.grey[700], fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_monsieurGold, _bronzeAccent]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _bronzeAccent.withValues(alpha: 0.3), blurRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
