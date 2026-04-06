import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final companies = ["GLOBAL LOGISTICS LTD.", "SECURE TRANSPORT SYSTEMS", "METRO DYNAMICS", "ALPHA CONNECT", "OMEGA VENTURES", "TITAN MOBILITY", "INFINITY SOLUTIONS"];
    final districts = ["CENTRAL", "EAST", "WEST", "NORTH", "SOUTH", "DOWNTOWN", "HARBOR", "VALLEY", "PLATEAU", "SUBURB"];
    final units = ["CENTRAL OVERSIGHT UNIT", "FINANCIAL AUDIT DIVISION", "REGULATORY COMPLIANCE", "SYSTEM INTEGRITY BRANCH", "OPERATIONAL CONTROL", "STRATEGIC ANALYSIS", "RISK MANAGEMENT"];
    final suspects = ["ENTITY-A", "ENTITY-B", "ENTITY-C"];
    
    for (int i = 0; i < 100; i++) {
      bool isError = Random().nextDouble() < 0.18;
      data.add({
        "id": i,
        "tc": _pendingApprovals[i],
        "unit": units[Random().nextInt(units.length)],
        "courthouse": "${districts[Random().nextInt(districts.length)]} OFFICE",
        "relay": "[NODE-${districts[Random().nextInt(districts.length)]}]",
        "timestamp": DateTime.now(),
        "isError": isError,
        "company": companies[Random().nextInt(companies.length)],
        "suspect": suspects[Random().nextInt(suspects.length)],
        "detail": isError ? "INTEGRITY_MISMATCH" : "ROUTINE_AUDIT_PASSED",
        "hash": isError ? "ERR_B404" : "OK_200",
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
    setState(() => _stage = OperationStage.queue);
  }

  void _runOperation() async {
    setState(() {
      _stage = OperationStage.auth;
      _authProgress = 0.0;
      _logs.clear();
    });

    final authSteps = ["ENCRYPTING...", "VERIFYING...", "SYNCING...", "GRANTED"];
    for (int i = 0; i < authSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _authMessage = authSteps[i];
        _authProgress = (i + 1) / authSteps.length;
      });
    }

    if (mounted) setState(() => _stage = OperationStage.running);
    _startLogGeneration();
  }

  void _startLogGeneration() {
    int counter = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (counter >= _preGeneratedData.length) {
        timer.cancel();
        if (mounted) setState(() => _stage = OperationStage.completed);
        return;
      }
      if (mounted) {
        setState(() => _logs.insert(0, _preGeneratedData[counter++]));
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _metricsTimer?.cancel();
    _timeStreamSubscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMetricsBar(),
            const Divider(color: Colors.white10, height: 1),
            if (_stage == OperationStage.standby) _buildInitialState(),
            if (_stage == OperationStage.queue) _buildQueueState(),
            if (_stage == OperationStage.auth) _buildAuthState(),
            if (_stage == OperationStage.running || _stage == OperationStage.completed) _buildRunningState(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text('STATUS: LIVE', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          const Spacer(),
          Text(DateFormat('HH:mm:ss').format(DateTime.now()), style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMetricsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white.withValues(alpha: 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MetricBox(label: 'CPU', value: '${_cpuUsage.toStringAsFixed(1)}%', color: Colors.cyanAccent),
          _MetricBox(label: 'RAM', value: '${_ramUsage.toStringAsFixed(1)}%', color: Colors.purpleAccent),
          _MetricBox(label: 'NET', value: '${_netSpeed.toStringAsFixed(0)} Mbps', color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRadar(),
          const SizedBox(height: 40),
          Text('SYSTEM INTEGRITY', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _buildAction('INITIALIZE', _startQueueReview),
        ],
      ),
    );
  }

  Widget _buildRadar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Container(
        width: 100, height: 100,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent.withValues(alpha: 1 - _pulseController.value))),
      ),
    );
  }

  Widget _buildQueueState() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _pendingApprovals.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('REF: ${_pendingApprovals[index]}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                leading: const Icon(Icons.pending, color: Colors.orangeAccent, size: 14),
              ),
            ),
          ),
          _buildAction('START', _runOperation),
        ],
      ),
    );
  }

  Widget _buildAuthState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 20),
          Text(_authMessage, style: const TextStyle(color: Colors.cyanAccent)),
        ],
      ),
    );
  }

  Widget _buildRunningState() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _logs.length,
        itemBuilder: (context, index) => _LogItem(log: _logs[index]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(padding: const EdgeInsets.all(15), child: const Text('© 2026 KONUM SYSTEMS', style: TextStyle(color: Colors.white10, fontSize: 8)));
  }

  Widget _buildAction(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(onPressed: onTap, child: Text(text)),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MetricBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8)), Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))]);
  }
}

class _LogItem extends StatelessWidget {
  final Map<String, dynamic> log;
  const _LogItem({required this.log});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: log['isError'] ? Colors.red : Colors.green, width: 2))),
      child: Text('${log['company']} - ${log['detail']}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }
}
