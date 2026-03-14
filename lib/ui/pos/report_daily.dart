import 'package:flutter/material.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReportDailyScreen extends StatefulWidget {
  const ReportDailyScreen({super.key});

  @override
  State<ReportDailyScreen> createState() => _ReportDailyScreenState();
}

class _ReportDailyScreenState extends State<ReportDailyScreen> {
  final List<_SaleDetail> _allSales = const [
    _SaleDetail(
      receiptId: '#R-2101',
      dateTime: '2026-03-03 09:30',
      customer: 'Emma Wilson',
      service: 'Haircut',
      payment: 'cash',
      amount: 25.0,
    ),
    _SaleDetail(
      receiptId: '#R-2102',
      dateTime: '2026-03-03 10:15',
      customer: 'Noah Kim',
      service: 'Facial',
      payment: 'card',
      amount: 45.0,
    ),
    _SaleDetail(
      receiptId: '#R-2103',
      dateTime: '2026-03-05 14:20',
      customer: 'Olivia Tan',
      service: 'Manicure',
      payment: 'cash',
      amount: 30.0,
    ),
    _SaleDetail(
      receiptId: '#R-2104',
      dateTime: '2026-03-07 16:10',
      customer: 'James Park',
      service: 'Massage',
      payment: 'card',
      amount: 70.0,
    ),
    _SaleDetail(
      receiptId: '#R-2105',
      dateTime: '2026-03-10 11:00',
      customer: 'Liam Carter',
      service: 'Pedicure',
      payment: 'card',
      amount: 35.0,
    ),
    _SaleDetail(
      receiptId: '#R-2106',
      dateTime: '2026-03-11 13:45',
      customer: 'Mia Tran',
      service: 'Hair Color',
      payment: 'cash',
      amount: 60.0,
    ),
    _SaleDetail(
      receiptId: '#R-2107',
      dateTime: '2026-03-12 10:00',
      customer: 'Sophia Nguyen',
      service: 'Highlights',
      payment: 'card',
      amount: 80.0,
    ),
    _SaleDetail(
      receiptId: '#R-2108',
      dateTime: '2026-03-12 15:10',
      customer: 'Ava Brown',
      service: 'Blow Dry',
      payment: 'cash',
      amount: 20.0,
    ),
    _SaleDetail(
      receiptId: '#R-2109',
      dateTime: '2026-03-14 12:40',
      customer: 'Daniel Lee',
      service: 'Eyebrow Wax',
      payment: 'cash',
      amount: 15.0,
    ),
  ];

  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final dates = _allSales.map((e) => e.dateOnly).toList()..sort();
    _fromDate = dates.first;
    _toDate = dates.last;
  }

  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _fmtShort(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$m-$day';
  }

  List<_SaleDetail> get _filteredSales {
    final from = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final to = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);
    return _allSales.where((s) {
      final d = s.date;
      return !d.isBefore(from) && !d.isAfter(to);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DateTime _weekStart(DateTime d) {
    final only = DateTime(d.year, d.month, d.day);
    return only.subtract(Duration(days: only.weekday - 1));
  }

  Map<DateTime, List<_SaleDetail>> _groupByWeek(List<_SaleDetail> sales) {
    final map = <DateTime, List<_SaleDetail>>{};
    for (final s in sales) {
      final weekKey = _weekStart(s.date);
      map.putIfAbsent(weekKey, () => []).add(s);
    }
    return map;
  }

  Map<DateTime, List<_SaleDetail>> _groupByDay(List<_SaleDetail> sales) {
    final map = <DateTime, List<_SaleDetail>>{};
    for (final s in sales) {
      map.putIfAbsent(s.dateOnly, () => []).add(s);
    }
    return map;
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
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filteredSales;
    final weekMap = _groupByWeek(sales);
    final weekKeys = weekMap.keys.toList()..sort((a, b) => b.compareTo(a));

    final totalIncome = sales.fold<double>(0, (sum, s) => sum + s.amount);
    final cashIncome = sales
        .where((s) => s.payment.toLowerCase() == 'cash')
        .fold<double>(0, (sum, s) => sum + s.amount);
    final cardIncome = sales
        .where((s) => s.payment.toLowerCase() == 'card')
        .fold<double>(0, (sum, s) => sum + s.amount);

    return Scaffold(
      drawer: const AppDrawerPos(),
      appBar: AppBar(
        title: const Text('Daily Report'),
      ),
      body: Container(
        color: const Color(0xFFF4F6FA),
        child: Column(
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
                      value: '\$${totalIncome.toStringAsFixed(2)}',
                      color: const Color(0xFF3E66C5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Cash',
                      value: '\$${cashIncome.toStringAsFixed(2)}',
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Card',
                      value: '\$${cardIncome.toStringAsFixed(2)}',
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sales.isEmpty
                  ? const Center(
                      child: Text(
                        'No sales in selected date range',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: weekKeys.length,
                      itemBuilder: (context, weekIndex) {
                        final weekKey = weekKeys[weekIndex];
                        final weekSales = weekMap[weekKey]!;
                        final weekTotal = weekSales.fold<double>(
                          0,
                          (sum, s) => sum + s.amount,
                        );

                        final dayMap = _groupByDay(weekSales);
                        final dayKeys = dayMap.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Week ${_fmtDate(weekKey)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${weekTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFF3E66C5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                for (final day in dayKeys) ...[
                                  Builder(
                                    builder: (context) {
                                      final daySales = dayMap[day]!;
                                      final dayTotal = daySales.fold<double>(
                                        0,
                                        (sum, s) => sum + s.amount,
                                      );

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFF),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Day ${_fmtDate(day)}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '\$${dayTotal.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF2E7D32),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            for (final s in daySales)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${_fmtShort(s.date)} ${s.timeOnly}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        '${s.customer} • ${s.service}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 58,
                                                      child: Text(
                                                        s.payment.toUpperCase(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: s.payment ==
                                                                  'cash'
                                                              ? const Color(
                                                                  0xFF2E7D32)
                                                              : const Color(
                                                                  0xFF1565C0),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 70,
                                                      child: Text(
                                                        '\$${s.amount.toStringAsFixed(2)}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
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
        ),
      ),
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

class _SaleDetail {
  final String receiptId;
  final String dateTime;
  final String customer;
  final String service;
  final String payment;
  final double amount;

  const _SaleDetail({
    required this.receiptId,
    required this.dateTime,
    required this.customer,
    required this.service,
    required this.payment,
    required this.amount,
  });

  DateTime get date => DateTime.parse(dateTime.replaceAll(' ', 'T'));

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  String get timeOnly => dateTime.split(' ').last;
}
