import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../models/ride_model.dart';
import '../../utils/app_colors.dart';
import '../../services/app_notifier.dart';

class RideCompletionScreen extends StatefulWidget {
  final Ride ride;
  const RideCompletionScreen({super.key, required this.ride});

  @override
  State<RideCompletionScreen> createState() => _RideCompletionScreenState();
}

class _RideCompletionScreenState extends State<RideCompletionScreen> {
  static Color get _monsieurGold => AppColors.primary;
  static const Color _richBlack = Color(0xFF0A0A0A);

  String _paymentMethod = 'cash'; // Varsayılan: Nakit (Eğer yasal sınırın altındaysa)
  String _driverIban = '';
  bool _isLoadingIban = false;

  @override
  void initState() {
    super.initState();
    // VUK kuralı: 7.000 TL ve üstü mecburi Havale
    if (widget.ride.grossTotal >= 6950) {
      _paymentMethod = 'transfer';
    }
    
    // Şoförün güncel IBAN'ını Cloud Firestore'dan çek (Gerçek zamanlı en doğru IBAN)
    _fetchDriverIban();
  }

  Future<void> _fetchDriverIban() async {
    if (widget.ride.driverId == null) return;
    setState(() => _isLoadingIban = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('drivers').doc(widget.ride.driverId).get();
      if (doc.exists && doc.data()!.containsKey('iban')) {
        setState(() {
          _driverIban = doc.data()!['iban'] ?? '';
        });
      }
    } catch(e) {
      debugPrint("IBAN çekilemedi: $e");
    } finally {
      setState(() => _isLoadingIban = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppNotifier.snackbar("Kopyalandı", "$label kopyalandı.", backgroundColor: Colors.black87, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final bool isCashAllowed = ride.grossTotal < 6950;

    return Scaffold(
      backgroundColor: _richBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20), 
          onPressed: () => Get.offAllNamed('/passenger-home')
        ),
        title: Text(
          'HUKUKİ ÖDEME BEYANI', 
          style: GoogleFonts.spaceGrotesk(
            color: _monsieurGold, 
            fontWeight: FontWeight.w900, 
            fontSize: 14,
            letterSpacing: 2,
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // E-Fatura / Ücret Kartı
            _card([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader('FATURA ÖZETİ'),
                  Text(
                    ride.invoiceNo.isNotEmpty ? ride.invoiceNo : 'KN-XXXX', 
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _fareRow('KESİNLEŞEN BEDEL', ride.grossTotal, isBold: true),
              const SizedBox(height: 5),
              Text(
                'Yukarıdaki bedel haricinde hiçbir ek ücret talep edilemez.',
                style: TextStyle(color: Colors.red[300], fontSize: 10, fontStyle: FontStyle.italic),
              )
            ]),
            
            const SizedBox(height: 20),

            // ÖDEME SEÇİMİ (VUK UYUMLU)
            _card([
              _sectionHeader('ÖDEME YÖNTEMİ SEÇİMİ'),
              const SizedBox(height: 15),
              
              if (isCashAllowed) ...[
                _buildPaymentOption(
                  id: 'cash',
                  title: 'Nakit Ödeme',
                  icon: Icons.payments_rounded,
                  description: 'Araba içinde şoföre elden ödeyin.',
                ),
                const SizedBox(height: 10),
              ],
              
              _buildPaymentOption(
                id: 'transfer',
                title: 'Banka Havalesi',
                icon: Icons.account_balance_rounded,
                description: 'Şoförün resmi hesabına anında transfer.',
              ),
              
              const SizedBox(height: 15),
              
              // Seçime Göre Çıkan Dinamik Bölge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _paymentMethod == 'cash' 
                    ? _buildCashWarning() 
                    : _buildBankTransferInfo(ride.invoiceNo),
              ),
            ]),
            
            const SizedBox(height: 30),

            // Onay / Makbuz İndirme Butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AppNotifier.snackbar("Bilgi", "PDF E-Makbuz yakında entegre edilecek."),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Makbuz İndir', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[600]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed('/passenger-home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _monsieurGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'ANA EKRANA DÖN', 
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required String id, required String title, required IconData icon, required String description}) {
    final bool isSelected = _paymentMethod == id;
    
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _paymentMethod = id;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? _monsieurGold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _monsieurGold : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _monsieurGold : Colors.grey, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
            if (isSelected) 
               Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCashWarning() {
    return Container(
      key: const ValueKey('cash'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        border: Border(left: BorderSide(color: Colors.redAccent, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'VUK Tebliğleri uyarınca 7.000 TL altı kira bedelleri nakden tahsil edilebilir. Ödemenizi şoföre fiziken yapınız.',
              style: GoogleFonts.publicSans(color: Colors.red[200], fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferInfo(String invoiceNo) {
    return Container(
      key: const ValueKey('transfer'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Text('Şoförün Yasal İban Numarası', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          
          if (_isLoadingIban)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_driverIban.isEmpty)
            Text('Şoför henüz IBAN tanımlamamış. Lütfen nakit ödeme yapınız.', style: TextStyle(color: Colors.grey[500], fontSize: 12))
          else ...[
             // IBAN Kutu
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
               decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Expanded(
                     child: Text(_driverIban, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold)),
                   ),
                   IconButton(
                     padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                     icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 18),
                     onPressed: () => _copyToClipboard(_driverIban, 'IBAN Numarası'),
                   )
                 ],
               ),
             ),
             const SizedBox(height: 15),
             Text('Açıklama Kısmına Şunu Yazınız:', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
             const SizedBox(height: 5),
             // Açıklama Kutu
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(invoiceNo, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                   IconButton(
                     padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                     icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 18),
                     onPressed: () => _copyToClipboard(invoiceNo, 'Fatura No/Açıklama'),
                   )
                 ],
               ),
             ),
          ]
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String text) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: _monsieurGold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(
          text, 
          style: GoogleFonts.spaceGrotesk(color: _monsieurGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)
        ),
      ],
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: GoogleFonts.publicSans(
            color: isBold ? Colors.white : Colors.grey[500],
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ))),
          Text(
            '₺${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              color: isBold ? _monsieurGold : Colors.white,
              fontSize: isBold ? 24 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
