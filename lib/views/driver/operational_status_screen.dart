import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/brand_config.dart';
import '../../utils/app_colors.dart';

class OperationalStatusScreen extends StatefulWidget {
  const OperationalStatusScreen({super.key});

  @override
  State<OperationalStatusScreen> createState() => _OperationalStatusScreenState();
}

enum OperationStage { standby, queue, auth, running, completed }

class _OperationalStatusScreenState extends State<OperationalStatusScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _logs = [];
  final List<String> _pendingApprovals = [];
  late List<Map<String, dynamic>> _preGeneratedData;
  
  OperationStage _stage = OperationStage.standby;
  String _authMessage = "";
  double _authProgress = 0.0;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  late StreamSubscription<DateTime> _timeStreamSubscription;
  late AnimationController _pulseController;

  double _cpuUsage = 0.0;
  double _ramUsage = 0.0;
  double _netSpeed = 0.0;
  Timer? _metricsTimer;

  final Map<String, Map<String, dynamic>> _systemStatus = {
    "UYAP (ADALET)": {"status": null, "message": "", "retries": 0},
    "POLNET (EMNIYET)": {"status": null, "message": "", "retries": 0},
    "MASAK (MALIYE)": {"status": null, "message": "", "retries": 0},
    "CIMER (BASKANLIK)": {"status": null, "message": "", "retries": 0},
    "VEDOP (GIB)": {"status": null, "message": "", "retries": 0},
  };

  @override
  void initState() {
    super.initState();
    _generatePendingQueue();
    _preGeneratedData = _generateAllDataInAdvance();
    
    Stream<DateTime> timeStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
    _timeStreamSubscription = timeStream.listen((_) {
      if (mounted) setState(() {});
    });
    
    _startMetricsSimulation();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _generatePendingQueue() {
    _pendingApprovals.clear();
    for (int i = 0; i < 100; i++) {
      _pendingApprovals.add("${Random().nextInt(899) + 100} *** ** ${Random().nextInt(89) + 10}");
    }
  }

  List<Map<String, dynamic>> _generateAllDataInAdvance() {
    final List<Map<String, dynamic>> data = [];
    final companies = [
      "HGS SOSYAL HIZMETLER A.Ş.",
      "HGS TEMIZLIK",
      "BIRMAN DANISMANLIK",
      "SELIMIYE MERCUR",
      "TEKNE ISTANBUL",
      "HGS YÖNETİM DANIŞMANLIĞI",
      "HGS İLAÇLAMA & DEZENFEKSİYON"
    ];
    final districts = [
      "BAKIRKÖY", "BEŞİKTAŞ", "KADIKÖY", "ÜSKÜDAR", "ŞİŞLİ", 
      "SARIYER", "BEYOĞLU", "FATİH", "MALTEPE", "KARTAL",
      "PENDİK", "TUZLA", "ATAŞEHİR", "ÜMRANİYE", "BAŞAKŞEHİR"
    ];
    final units = [
      "CUMHURİYET BAŞSAVCILIĞI (ADLİ MUHABERE)",
      "İL EMNİYET MÜDÜRLÜĞÜ (MALİ ŞUBE)",
      "VERGİ DENETİM KURULU (İSTANBUL BŞK.)",
      "TAPU VE KADASTRO BÖLGE MÜDÜRLÜĞÜ",
      "İSTANBUL DEFTERDARLIĞI (MUHAKEMAT)",
      "BÜYÜKŞEHİR BELEDİYESİ (TEFTİŞ KURULU)",
      "VALİLİK YATIRIM İZLEME VE KOORDİNASYON"
    ];
    final suspects = ["HÜSEYİN SONGUR", "ADEM SONGUR"];
    
    for (int i = 0; i < 100; i++) {
      bool isError = Random().nextDouble() < 0.18;
      String company = companies[Random().nextInt(companies.length)];
      String suspect = suspects[Random().nextInt(suspects.length)];
      String district = districts[Random().nextInt(districts.length)];
      String unit = units[Random().nextInt(units.length)];
      
      data.add({
        "id": i,
        "tc": _pendingApprovals[i],
        "unit": unit,
        "district": district,
        "courthouse": "$district ADLİYESİ",
        "ip": "212.156.${Random().nextInt(255)}.${Random().nextInt(255)}",
        "mac": List.generate(6, (_) => Random().nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase()).join(':'),
        "port": "SAHTE-SENET:V5",
        "gps": "${(36.0 + Random().nextDouble() * 6.0).toStringAsFixed(4)}° N, ${(26.0 + Random().nextDouble() * 19.0).toStringAsFixed(4)}° E",
        "hash": isError ? "TCK-158/204:NITELIKLI_DOLANDIRICILIK" : "TCK-220:ORGANİZE_SUÇ_KAPSAMI",
        "relay": "[ORTAKYOL-$district-NODE]",
        "timestamp": DateTime.now(),
        "isError": isError,
        "company": company,
        "suspect": suspect,
        "detail": isError ? "SAHTE POLİÇE / EULER-HERMES RED" : "AXA_SAHTE_KEFALET_SORGUSU",
      });
    }
    return data;
  }

  void _startMetricsSimulation() {
    _metricsTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _cpuUsage = 10 + Random().nextDouble() * 45;
          _ramUsage = 30 + Random().nextDouble() * 20;
          _netSpeed = 100 + Random().nextDouble() * 800;
        });
      }
    });
  }

  void _startQueueReview() {
    setState(() {
      _stage = OperationStage.queue;
    });
    HapticFeedback.lightImpact();
  }

  void _runOperation() async {
    setState(() {
      _stage = OperationStage.auth;
      _authProgress = 0.0;
      _logs.clear();
    });

    final systems = _systemStatus.keys.toList();
    for (var system in systems) {
      if (!mounted) return;
      setState(() { _authMessage = "$system SİSTEMİNE BAĞLANILIYOR..."; });
      await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(400)));
      
      if (Random().nextDouble() < 0.25) {
        setState(() {
          _systemStatus[system]!["status"] = false;
          _systemStatus[system]!["message"] = "ZAMAN AŞIMI";
          _authMessage = "$system - BAĞLANTI HATASI! YENİDEN DENENYOR...";
        });
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 600));
      }
      
      setState(() {
        _systemStatus[system]!["status"] = true;
        _systemStatus[system]!["message"] = "BAĞLANDI";
      });
      HapticFeedback.mediumImpact();
    }

    final authSteps = [
      "Hüseyin & Adem Songur Dosyası Taratılıyor...",
      "HGS Sosyal Hizmetler A.Ş. VKN Kayıtları Çekildi.",
      "AXA & Euler Hermes Sahte Senetler Eşleştiriliyor.",
      "TCK 158/204 & CMK 135 Protokolleri Aktive Edildi.",
      "OPERASYONEL MÜDAHALE İÇİN ADLİ YETKİ ALINDI."
    ];

    for (int i = 0; i < authSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _authMessage = authSteps[i];
        _authProgress = (i + 1) / authSteps.length;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(300)));
    }

    if (!mounted) return;
    setState(() { _stage = OperationStage.running; });

    int count = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (count < 100) {
        setState(() {
          var data = Map<String, dynamic>.from(_preGeneratedData[count]);
          data["timestamp"] = DateTime.now();
          _logs.add(data);
          
          if (data["isError"] == true) {
            HapticFeedback.vibrate();
          } else {
            HapticFeedback.lightImpact();
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
        count++;
      } else {
        timer.cancel();
        setState(() { _stage = OperationStage.completed; });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _showTJKReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF020408),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F1E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(5)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(25),
                  children: [
                    const Center(child: Text("🚩 AÇIK İHBAR 🚩", style: TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2))),
                    const SizedBox(height: 20),
                    const Center(child: Text("TJK'de Sahte Kefalet Şebekesi", style: TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.w900, fontSize: 24, fontStyle: FontStyle.italic))),
                    const Center(child: Text("Hüseyin Songur - Adem Songur Operasyonu", style: TextStyle(color: Color(0xFF1E3A5F), fontSize: 16, fontWeight: FontWeight.bold))),
                    const Divider(height: 40, thickness: 2, color: Color(0xFF8B0000)),
                    _reportRow("Dosya No", "856975-SD-02"),
                    _reportRow("Tarih", "25.03.2026"),
                    _reportRow("Tutar", "14.100.000 TL"),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFF8B0000), borderRadius: BorderRadius.circular(8)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🔴 KRİTİK VURGU: BU BİR 'PRİM ÖDENMEMESİ' DEĞİLDİR!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 10),
                          Text(
                            "Hüseyin Songur ve Adem Songur isimli şahıslar, TJK nezdinde düzenlenen ihalelerde, 14.100.000,00 TL teminat tutarlı kefalet senedini baştan sona sahte olarak düzenleterek kullanmışlardır.",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("🐎 Bağlantılı Firmalar:", style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    _bulletItem("HGS Sosyal Hizmetler A.Ş."),
                    _bulletItem("Birman Danışmanlık"),
                    _bulletItem("Naturel Temizlik"),
                    _bulletItem("HGS Temizlik"),
                    _bulletItem("Tekne İstanbul"),
                    const Divider(height: 40),
                    const Text("⚖️ Hukuki İhlaller:", style: TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    _bulletItem("TCK 158: Nitelikli Dolandırıcılık"),
                    _bulletItem("TCK 204: Resmî Belgede Sahtecilik"),
                    _bulletItem("TCK 235: İhaleye Fesat Karıştırma"),
                    const SizedBox(height: 50),
                    const Text("© 2026 T.C. ADALET VE İÇİŞLERİ BAKANLIKLARI", style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF8B0000), size: 14),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _metricsTimer?.cancel();
    _timeStreamSubscription.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 150,
                itemBuilder: (context, index) => Container(
                  height: 1,
                  color: Colors.blueAccent,
                  margin: const EdgeInsets.only(bottom: 2),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSystemStatusBar(),
                _buildMainHeader(),
                _buildMetricsAndStatus(),
                _buildInfoCard(),
                if (_stage == OperationStage.standby)
                  _buildStandbyState()
                else if (_stage == OperationStage.queue)
                  _buildQueueState()
                else if (_stage == OperationStage.auth)
                  _buildAuthState()
                else
                  _buildRunningState(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.hub, color: AppColors.primary, size: 12),

              const SizedBox(width: 8),
              Text(
                'MÜŞTEREK ADLİ HAREKAT TERMİNALİ // HEIMDAL V5.0',
                style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          StreamBuilder<DateTime>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
            builder: (context, snapshot) {
              return Text(
                DateFormat('HH:mm:ss.SS').format(snapshot.data ?? DateTime.now()),
                style: GoogleFonts.spaceGrotesk(color: AppColors.textDisabled, fontSize: 9, fontWeight: FontWeight.w500),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            '${BrandConfig.current.appName} // ADALET VE İÇİŞLERİ BAKANLIKLARI',

            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          FadeTransition(
            opacity: _pulseController,
            child: Text(
              'UYAP / POLNET / CIMER ENTEGRE OPERASYON MERKEZİ',
              style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsAndStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricBox(label: 'CPU', value: '${_cpuUsage.toStringAsFixed(1)}%', color: Colors.blue),
              _MetricBox(label: 'RAM', value: '${_ramUsage.toStringAsFixed(1)}%', color: Colors.blueAccent),
              _MetricBox(label: 'NET', value: '${_netSpeed.toStringAsFixed(0)} Mbps', color: Colors.cyanAccent),
              const _MetricBox(label: 'AUTH', value: 'SHA-512', color: Colors.amber),
            ],
          ),
          const Divider(color: AppColors.divider, height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: _systemStatus.entries.map((e) {
              Color statusColor = (e.value["status"] == true) ? Colors.greenAccent : (e.value["status"] == false ? Colors.redAccent : Colors.grey);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                  const SizedBox(width: 5),
                  Text(e.key, style: GoogleFonts.publicSans(color: AppColors.textDisabled, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DOSYA: 856975-SD-03 (SONGUR)', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('HAREKAT SEVİYESİ: KRİTİK', style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text('KONU: SİSTEMATİK SAHTECİLİK VE NİTELİKLİ DOLANDIRICILIK', style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 10)),
          Text('İLGİLİLER: Hüseyin Songur, Adem Songur, HGS Sosyal Hizmetler A.Ş.', style: GoogleFonts.publicSans(color: AppColors.primary.withValues(alpha: 0.7), fontSize: 8)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _showTJKReport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'TJK SAHTE TEMİNAT İHBAR DOSYASINI GÖRÜNTÜLE',
                    style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandbyState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance, color: AppColors.textDisabled, size: 60),
          const SizedBox(height: 15),
          Text('100 MAĞDUR ŞİKAYETİ EŞLEŞTİRİLİYOR', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Kurumsal sistemlerle (UYAP/POLNET) eşleşme bekleniyor.', style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: _startQueueReview,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardBg, minimumSize: const Size(double.infinity, 50), side: BorderSide(color: AppColors.divider)),
              child: Text('ONAY HAVUZUNU AÇ', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueState() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _pendingApprovals.length,
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(2)),
                child: Row(
                  children: [
                    Text('#${index + 1}', style: GoogleFonts.spaceGrotesk(color: AppColors.textDisabled, fontSize: 10)),
                    const SizedBox(width: 15),
                    Text('T.C.: ${_pendingApprovals[index]}', style: GoogleFonts.publicSans(color: Colors.white, fontSize: 11)),
                    const Spacer(),
                    Icon(Icons.verified, color: AppColors.primary, size: 14),

                  ],
                ),
              ),
            ),
          ),
          _buildActionButton('ADLİ HAREKATI BAŞLAT', _runOperation),
        ],
      ),
    );
  }

  Widget _buildAuthState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),

          const SizedBox(height: 30),
          Text(_authMessage, style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: LinearProgressIndicator(value: _authProgress, color: AppColors.primary, backgroundColor: AppColors.divider),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningState() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        itemCount: _logs.length + (_stage == OperationStage.completed ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _logs.length) return _buildFinalStatus();
          return _LogItem(log: _logs[index]);
        },
      ),
    );
  }

  Widget _buildFinalStatus() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(top: 20, bottom: 60),
      decoration: BoxDecoration(color: const Color(0xFF0F1B12), border: Border.all(color: Colors.greenAccent, width: 1.5), borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          const Icon(Icons.gavel, color: Colors.greenAccent, size: 40),
          const SizedBox(height: 15),
          Text('HGS SOSYAL HİZMETLER VE SONGUR DOSYASI TAMAMLANDI', style: GoogleFonts.spaceGrotesk(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Hüseyin ve Adem Songur tarafından düzenlenen sahte kefalet senetleri, Euler Hermes, AXA ve Face Sigorta kayıtları eşleştirilerek TCK 158/204, 235 ve 220 maddeleri uyarınca adli makamlara sevk edilmiştir.', textAlign: TextAlign.center, style: GoogleFonts.publicSans(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 20),
          Text('TRACE SCAN: CLEAN // FILE STATUS: TRANSMITTED', style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Text('© 2026 T.C. ADALET VE İÇİŞLERİ BAKANLIKLARI - DİJİTAL SİSTEMLER', style: GoogleFonts.spaceGrotesk(color: AppColors.textDisabled, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 55)),
        child: Text(text, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(label, style: GoogleFonts.spaceGrotesk(color: AppColors.textDisabled, fontSize: 8)), Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'))]);
  }
}

class _LogItem extends StatelessWidget {
  final Map<String, dynamic> log;
  const _LogItem({required this.log});
  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm:ss.SSS').format(log['timestamp'] ?? DateTime.now());
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: log['isError'] == true ? const Color(0xFF241313) : AppColors.cardBg, border: Border(left: BorderSide(color: log['isError'] == true ? Colors.redAccent : AppColors.primary.withValues(alpha: 0.5), width: 3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text('$formattedTime ', style: TextStyle(color: log['isError'] == true ? Colors.redAccent : Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace')), Text('${log['relay']} ', style: TextStyle(color: log['isError'] == true ? Colors.redAccent : Colors.cyanAccent, fontSize: 8, fontWeight: FontWeight.bold)), const Spacer()]),
          const SizedBox(height: 4),
          Text('BİRİMLER: ${log['unit']}', style: TextStyle(color: log['isError'] == true ? Colors.redAccent.withValues(alpha: 0.9) : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${log['company']} // SUÇLU: ${log['suspect']}', style: TextStyle(color: log['isError'] == true ? Colors.redAccent : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('YER: ${log['courthouse']} // TESPİT: ${log['detail']}', style: TextStyle(color: log['isError'] == true ? Colors.redAccent.withValues(alpha: 0.7) : Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
          Text('T.C. KİMLİK: ${log['tc']} // PROTOKOL: ${log['hash']}', style: TextStyle(color: log['isError'] == true ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }
}
