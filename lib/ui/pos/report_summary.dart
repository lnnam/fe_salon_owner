import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  bool _isLoading = true;
  String? _error;
  _DailySummary? _summary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(const Duration(days: 13));
    _loadDailySummary();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _loadDailySummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await apiManager.getPosDailySummary(
        from: _formatDate(_fromDate),
        to: _formatDate(_toDate),
      );
      setState(() {
        _summary = _DailySummary.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
    );
    if (picked == null) return;
    setState(() {
      _fromDate = DateTime(picked.year, picked.month, picked.day);
    });
    await _loadDailySummary();
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _toDate = DateTime(picked.year, picked.month, picked.day);
    });
    await _loadDailySummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerPos(),
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/report-daily');
            },
            icon:
                const Icon(Icons.today_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Daily',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF4F6FA),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 42),
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadDailySummary,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _summary == null
                    ? const Center(child: Text('No report data'))
                    : _buildContent(_summary!),
      ),
    );
  }

  Widget _buildContent(_DailySummary summary) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _DatePickTile(
                  label: 'Date From',
                  value: _formatDate(_fromDate),
                  onTap: _pickFromDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DatePickTile(
                  label: 'Date To',
                  value: _formatDate(_toDate),
                  onTap: _pickToDate,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ReportCard(
                title: 'Total Sales',
                value: '\$${summary.totalSales.toStringAsFixed(2)}',
                icon: Icons.payments_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ReportCard(
                title: 'Receipts',
                value: '${summary.receipts}',
                icon: Icons.receipt_long_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ReportCard(
                title: 'Cash Total',
                value: '\$${summary.cashTotal.toStringAsFixed(2)}',
                icon: Icons.money_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ReportCard(
                title: 'Card Total',
                value: '\$${summary.cardTotal.toStringAsFixed(2)}',
                icon: Icons.credit_card_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ReportCard(
          title: 'Average Ticket',
          value: '\$${summary.averageTicket.toStringAsFixed(2)}',
          icon: Icons.analytics_rounded,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Mix',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (summary.paymentMix.isEmpty)
                const Text('No payment mix data',
                    style: TextStyle(color: Colors.grey))
              else
                for (final p in summary.paymentMix)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PaymentBar(
                      label: p.method,
                      amount: p.amount,
                      percentage: p.percentage,
                      color: p.method.toLowerCase() == 'cash'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF3E66C5),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Services',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (summary.topServices.isEmpty)
                const Text('No top services data',
                    style: TextStyle(color: Colors.grey))
              else
                for (final s in summary.topServices)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('x${s.quantity}'),
                        const SizedBox(width: 10),
                        Text(
                          '\$${s.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatePickTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8E1F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.date_range_rounded,
                    size: 18, color: Color(0xFF3E66C5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3E66C5)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBar extends StatelessWidget {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const _PaymentBar({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
                '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: const Color(0xFFE8EEF8),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _DailySummary {
  final DateTime dateFrom;
  final DateTime dateTo;
  final double totalSales;
  final int receipts;
  final double cashTotal;
  final double cardTotal;
  final double averageTicket;
  final List<_PaymentMix> paymentMix;
  final List<_TopService> topServices;

  const _DailySummary({
    required this.dateFrom,
    required this.dateTo,
    required this.totalSales,
    required this.receipts,
    required this.cashTotal,
    required this.cardTotal,
    required this.averageTicket,
    required this.paymentMix,
    required this.topServices,
  });

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDate(dynamic value) {
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  factory _DailySummary.fromJson(Map<String, dynamic> json) {
    final mixRaw = (json['payment_mix'] as List<dynamic>? ?? []);
    final topRaw = (json['top_services'] as List<dynamic>? ?? []);
    final fallbackDate = _toDate(json['date']);

    return _DailySummary(
      dateFrom: _toDate(json['date_from'] ?? fallbackDate.toIso8601String()),
      dateTo: _toDate(json['date_to'] ?? fallbackDate.toIso8601String()),
      totalSales: _toDouble(json['total_sales']),
      receipts: _toInt(json['receipts']),
      cashTotal: _toDouble(json['cash_total']),
      cardTotal: _toDouble(json['card_total']),
      averageTicket: _toDouble(json['average_ticket']),
      paymentMix: mixRaw
          .whereType<Map>()
          .map((m) => _PaymentMix.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      topServices: topRaw
          .whereType<Map>()
          .map((m) => _TopService.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }
}

class _PaymentMix {
  final String method;
  final double amount;
  final double percentage;

  const _PaymentMix({
    required this.method,
    required this.amount,
    required this.percentage,
  });

  factory _PaymentMix.fromJson(Map<String, dynamic> json) {
    return _PaymentMix(
      method: (json['method'] ?? '').toString(),
      amount: _DailySummary._toDouble(json['amount']),
      percentage: _DailySummary._toDouble(json['percentage']),
    );
  }
}

class _TopService {
  final String name;
  final int quantity;
  final double amount;

  const _TopService({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  factory _TopService.fromJson(Map<String, dynamic> json) {
    return _TopService(
      name: (json['name'] ?? '').toString(),
      quantity: _DailySummary._toInt(json['quantity']),
      amount: _DailySummary._toDouble(json['amount']),
    );
  }
}
