import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReportDailyScreen extends StatefulWidget {
  const ReportDailyScreen({super.key});

  @override
  State<ReportDailyScreen> createState() => _ReportDailyScreenState();
}

class _ReportDailyScreenState extends State<ReportDailyScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  bool _isLoading = true;
  String? _error;
  _DailyReport? _report;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate.subtract(Duration(days: _toDate.weekday - 1));
    _loadReport();
  }

  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _fmtReceiptDateTime(String value) {
    final dt = DateTime.tryParse(value.replaceAll(' ', 'T'));
    if (dt == null) return value;

    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _fmtDayLabel(String value) {
    final dt = DateTime.tryParse(value.replaceAll(' ', 'T'));
    if (dt == null) return value;

    const dayNames = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final dayName = dayNames[dt.weekday - 1];
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString().padLeft(4, '0');
    return '$dayName , $dd - $mm - $yyyy';
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await apiManager.pos.getPosReportDaily(
        from: _fmtDate(_fromDate),
        to: _fmtDate(_toDate),
      );

      final parsed = _DailyReport.fromJson(data);

      setState(() {
        _report = parsed;
        _fromDate = parsed.dateFrom;
        _toDate = parsed.dateTo;
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
    setState(() => _fromDate = picked);
    await _loadReport();
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _toDate = picked);
    await _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerPos(),
      appBar: AppBar(
        title: const Text('Daily Report'),
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
                            onPressed: _loadReport,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final report = _report;

    final totalIncome = report?.totals.income ?? 0;
    final cashIncome = report?.totals.cash ?? 0;
    final cardIncome = report?.totals.card ?? 0;

    final weeks = report?.weeks ?? const <_ReportWeek>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Container(
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
                    value: _fmtDate(_fromDate),
                    onTap: _pickFromDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DatePickTile(
                    label: 'Date To',
                    value: _fmtDate(_toDate),
                    onTap: _pickToDate,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Income',
                  value: '\£${totalIncome.toStringAsFixed(2)}',
                  color: const Color(0xFF3E66C5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  title: 'Cash',
                  value: '\£${cashIncome.toStringAsFixed(2)}',
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  title: 'Card',
                  value: '\£${cardIncome.toStringAsFixed(2)}',
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: weeks.isEmpty
              ? const Center(
                  child: Text(
                    'No sales in selected date range',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: weeks.length,
                  itemBuilder: (context, weekIndex) {
                    final week = weeks[weekIndex];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTotalsRow(
                              title: 'Week ${week.weekStart}',
                              total: week.total,
                              totalColor: const Color(0xFF3E66C5),
                              cashTotal: week.cashTotal,
                              cardTotal: week.cardTotal,
                            ),
                            const SizedBox(height: 8),
                            for (final day in week.days) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionTotalsRow(
                                      title: _fmtDayLabel(day.date),
                                      titleStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      total: day.total,
                                      totalColor: const Color(0xFF2E7D32),
                                      cashTotal: day.cashTotal,
                                      cardTotal: day.cardTotal,
                                    ),
                                    const SizedBox(height: 6),
                                    for (final receipt in day.receipts)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                _fmtReceiptDateTime(
                                                    receipt.datetime),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                receipt.label,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 58,
                                              child: Text(
                                                receipt.paymentMethod
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: receipt.paymentMethod
                                                              .toLowerCase() ==
                                                          'cash'
                                                      ? const Color(0xFF2E7D32)
                                                      : receipt.paymentMethod
                                                                  .toLowerCase() ==
                                                              'card'
                                                          ? const Color(
                                                              0xFF1565C0)
                                                          : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                '\£${receipt.amount.toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTotalsRow extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final double total;
  final Color totalColor;
  final double cashTotal;
  final double cardTotal;

  const _SectionTotalsRow({
    required this.title,
    this.titleStyle,
    required this.total,
    required this.totalColor,
    required this.cashTotal,
    required this.cardTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: (titleStyle ??
                        const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ))
                    .copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            _AmountText(
              label: 'Total',
              amount: total,
              color: totalColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AmountText(
                label: 'Cash',
                amount: cashTotal,
                color: const Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: 16),
              _AmountText(
                label: 'Card',
                amount: cardTotal,
                color: const Color(0xFF1565C0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountText extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const _AmountText({
    required this.label,
    required this.amount,
    required this.color,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: \£${amount.toStringAsFixed(2)}',
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}

class _DailyReport {
  final DateTime dateFrom;
  final DateTime dateTo;
  final _ReportTotals totals;
  final List<_ReportWeek> weeks;

  const _DailyReport({
    required this.dateFrom,
    required this.dateTo,
    required this.totals,
    required this.weeks,
  });

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static double _readPaymentTotal(
    Map<String, dynamic> json,
    List<String> keys, {
    required double fallback,
  }) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return _toDouble(json[key]);
      }
    }
    return fallback;
  }

  static double _sumReceiptsByMethod(
    Iterable<_ReportReceipt> receipts,
    String method,
  ) {
    final normalizedMethod = method.trim().toLowerCase();
    return receipts
        .where(
          (receipt) =>
              receipt.paymentMethod.trim().toLowerCase() == normalizedMethod,
        )
        .fold<double>(0, (sum, receipt) => sum + receipt.amount);
  }

  static DateTime _toDate(dynamic value) {
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return DateTime.now();
  }

  factory _DailyReport.fromJson(Map<String, dynamic> json) {
    final totalsMap = Map<String, dynamic>.from(
      (json['totals'] as Map?) ?? const <String, dynamic>{},
    );

    final weekRaw = (json['weeks'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((m) => _ReportWeek.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    return _DailyReport(
      dateFrom: _toDate(json['date_from']),
      dateTo: _toDate(json['date_to']),
      totals: _ReportTotals(
        income: _toDouble(totalsMap['income']),
        cash: _toDouble(totalsMap['cash']),
        card: _toDouble(totalsMap['card']),
      ),
      weeks: weekRaw,
    );
  }
}

class _ReportTotals {
  final double income;
  final double cash;
  final double card;

  const _ReportTotals({
    required this.income,
    required this.cash,
    required this.card,
  });
}

class _ReportWeek {
  final String weekStart;
  final double total;
  final double cashTotal;
  final double cardTotal;
  final List<_ReportDay> days;

  const _ReportWeek({
    required this.weekStart,
    required this.total,
    required this.cashTotal,
    required this.cardTotal,
    required this.days,
  });

  factory _ReportWeek.fromJson(Map<String, dynamic> json) {
    final dayRaw = (json['days'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((m) => _ReportDay.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final cashTotal = _DailyReport._readPaymentTotal(
      json,
      ['cash_total', 'cash'],
      fallback: dayRaw.fold<double>(0, (sum, day) => sum + day.cashTotal),
    );
    final cardTotal = _DailyReport._readPaymentTotal(
      json,
      ['card_total', 'card'],
      fallback: dayRaw.fold<double>(0, (sum, day) => sum + day.cardTotal),
    );

    return _ReportWeek(
      weekStart: (json['week_start'] ?? '').toString(),
      total: _DailyReport._toDouble(json['total']),
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      days: dayRaw,
    );
  }
}

class _ReportDay {
  final String date;
  final double total;
  final double cashTotal;
  final double cardTotal;
  final List<_ReportReceipt> receipts;

  const _ReportDay({
    required this.date,
    required this.total,
    required this.cashTotal,
    required this.cardTotal,
    required this.receipts,
  });

  factory _ReportDay.fromJson(Map<String, dynamic> json) {
    final receiptRaw = (json['receipts'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((m) => _ReportReceipt.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final cashTotal = _DailyReport._readPaymentTotal(
      json,
      ['cash_total', 'cash'],
      fallback: _DailyReport._sumReceiptsByMethod(receiptRaw, 'cash'),
    );
    final cardTotal = _DailyReport._readPaymentTotal(
      json,
      ['card_total', 'card'],
      fallback: _DailyReport._sumReceiptsByMethod(receiptRaw, 'card'),
    );

    return _ReportDay(
      date: (json['date'] ?? '').toString(),
      total: _DailyReport._toDouble(json['total']),
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      receipts: receiptRaw,
    );
  }
}

class _ReportReceipt {
  final String saleKey;
  final String receiptNo;
  final String datetime;
  final String label;
  final String paymentMethod;
  final double amount;

  const _ReportReceipt({
    required this.saleKey,
    required this.receiptNo,
    required this.datetime,
    required this.label,
    required this.paymentMethod,
    required this.amount,
  });

  factory _ReportReceipt.fromJson(Map<String, dynamic> json) {
    String parseSaleKey() {
      for (final key in const [
        'sale_key',
        'saleKey',
        'salekey',
        'sale_id',
        'saleId',
        'pkey',
        'p_key',
        'id',
      ]) {
        final v = (json[key] ?? '').toString().trim();
        if (v.isNotEmpty &&
            v.toLowerCase() != 'null' &&
            v.toLowerCase() != 'nan') {
          return v;
        }
      }
      return '';
    }

    final parsedSaleKey = parseSaleKey();

    // receipt_no may arrive as a number – stringify then check for 'null'/'nan'
    String parseReceiptNo() {
      for (final key in const [
        'receipt_no',
        'receiptNo',
        'receipt_number',
      ]) {
        final v = (json[key] ?? '').toString().trim();
        if (v.isNotEmpty &&
            v.toLowerCase() != 'null' &&
            v.toLowerCase() != 'nan') {
          return v;
        }
      }
      return parsedSaleKey;
    }

    String parseLabel() {
      final raw = (json['label'] ?? '').toString();
      // strip NaN artifacts produced by some backends
      final cleaned =
          raw.replaceAll(RegExp(r'NaN', caseSensitive: false), '').trim();
      return cleaned;
    }

    return _ReportReceipt(
      saleKey: parsedSaleKey,
      receiptNo: parseReceiptNo(),
      datetime: (json['datetime'] ?? '').toString(),
      label: parseLabel(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      amount: _DailyReport._toDouble(json['amount']),
    );
  }
}
