import 'package:flutter/material.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Map<String, _ReportDayData> _reportByDate = {
    '2026-03-12': const _ReportDayData(
      totalSales: 250.0,
      receiptsCount: 4,
      cashTotal: 105.0,
      cardTotal: 145.0,
      topServices: [
        _TopService(name: 'Highlights', qty: 1, amount: 80.0),
        _TopService(name: 'Massage', qty: 1, amount: 70.0),
        _TopService(name: 'Facial', qty: 1, amount: 45.0),
      ],
    ),
    '2026-03-13': const _ReportDayData(
      totalSales: 185.0,
      receiptsCount: 3,
      cashTotal: 65.0,
      cardTotal: 120.0,
      topServices: [
        _TopService(name: 'Pedicure', qty: 2, amount: 70.0),
        _TopService(name: 'Haircut', qty: 2, amount: 50.0),
        _TopService(name: 'Manicure', qty: 1, amount: 30.0),
      ],
    ),
    '2026-03-14': const _ReportDayData(
      totalSales: 140.0,
      receiptsCount: 2,
      cashTotal: 40.0,
      cardTotal: 100.0,
      topServices: [
        _TopService(name: 'Hair Color', qty: 1, amount: 60.0),
        _TopService(name: 'Blow Dry', qty: 2, amount: 40.0),
        _TopService(name: 'Eyebrow Wax', qty: 2, amount: 30.0),
      ],
    ),
  };

  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = (_reportByDate.keys.toList()..sort()).last;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final dates = _reportByDate.keys.toList()..sort();
    final data = _reportByDate[_selectedDate]!;
    final avgTicket =
        data.receiptsCount == 0 ? 0.0 : data.totalSales / data.receiptsCount;

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
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: Color(0xFF3E66C5)),
                  const SizedBox(width: 8),
                  const Text(
                    'Date:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedDate,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: dates
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d,
                              child: Text(d),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedDate = value);
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Pick date',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(_selectedDate) ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked == null) return;
                      final pickedDate = _formatDate(picked);
                      if (_reportByDate.containsKey(pickedDate)) {
                        setState(() => _selectedDate = pickedDate);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No report data for $pickedDate',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.edit_calendar_rounded),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    title: 'Total Sales',
                    value: '\$${data.totalSales.toStringAsFixed(2)}',
                    icon: Icons.payments_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReportCard(
                    title: 'Receipts',
                    value: '${data.receiptsCount}',
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
                    value: '\$${data.cashTotal.toStringAsFixed(2)}',
                    icon: Icons.money_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReportCard(
                    title: 'Card Total',
                    value: '\$${data.cardTotal.toStringAsFixed(2)}',
                    icon: Icons.credit_card_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ReportCard(
              title: 'Average Ticket',
              value: '\$${avgTicket.toStringAsFixed(2)}',
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
                  _PaymentBar(
                    label: 'Cash',
                    amount: data.cashTotal,
                    total: data.totalSales,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 8),
                  _PaymentBar(
                    label: 'Card',
                    amount: data.cardTotal,
                    total: data.totalSales,
                    color: const Color(0xFF3E66C5),
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
                  for (final s in data.topServices)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text('x${s.qty}'),
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
  final double total;
  final Color color;

  const _PaymentBar({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total <= 0 ? 0.0 : (amount / total).clamp(0.0, 1.0);
    final pctText = (pct * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('\$${amount.toStringAsFixed(2)} ($pctText%)'),
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

class _ReportDayData {
  final double totalSales;
  final int receiptsCount;
  final double cashTotal;
  final double cardTotal;
  final List<_TopService> topServices;

  const _ReportDayData({
    required this.totalSales,
    required this.receiptsCount,
    required this.cashTotal,
    required this.cardTotal,
    required this.topServices,
  });
}

class _TopService {
  final String name;
  final int qty;
  final double amount;

  const _TopService({
    required this.name,
    required this.qty,
    required this.amount,
  });
}
