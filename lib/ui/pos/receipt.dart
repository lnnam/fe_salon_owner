import 'package:flutter/material.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final List<_ReceiptItem> _receipts = const [
    _ReceiptItem(
      id: '#R-1001',
      customer: 'Emma Wilson',
      dateTime: '2026-03-12 10:15',
      services: ['Haircut', 'Hair Wash'],
      total: 35.00,
      payment: 'cash',
    ),
    _ReceiptItem(
      id: '#R-1002',
      customer: 'Liam Carter',
      dateTime: '2026-03-12 11:40',
      services: ['Facial'],
      total: 45.00,
      payment: 'card',
    ),
    _ReceiptItem(
      id: '#R-1003',
      customer: 'Sophia Nguyen',
      dateTime: '2026-03-12 13:05',
      services: ['Highlights', 'Blow Dry'],
      total: 100.00,
      payment: 'card',
    ),
    _ReceiptItem(
      id: '#R-1004',
      customer: 'Noah Kim',
      dateTime: '2026-03-12 15:25',
      services: ['Massage'],
      total: 70.00,
      payment: 'cash',
    ),
    _ReceiptItem(
      id: '#R-1005',
      customer: 'Olivia Tan',
      dateTime: '2026-03-13 09:35',
      services: ['Manicure'],
      total: 30.00,
      payment: 'cash',
    ),
    _ReceiptItem(
      id: '#R-1006',
      customer: 'James Park',
      dateTime: '2026-03-13 14:50',
      services: ['Pedicure', 'Facial'],
      total: 80.00,
      payment: 'card',
    ),
    _ReceiptItem(
      id: '#R-1007',
      customer: 'Mia Tran',
      dateTime: '2026-03-14 11:20',
      services: ['Hair Color'],
      total: 60.00,
      payment: 'card',
    ),
  ];

  int? _selectedIndex;
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _receipts.first.dateOnly;
  }

  List<String> get _availableDates {
    final set = <String>{};
    for (final item in _receipts) {
      set.add(item.dateOnly);
    }
    final dates = set.toList()..sort();
    return dates;
  }

  List<_ReceiptItem> get _filteredReceipts {
    return _receipts.where((item) => item.dateOnly == _selectedDate).toList();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final filteredReceipts = _filteredReceipts;
    if (_selectedIndex != null && _selectedIndex! >= filteredReceipts.length) {
      _selectedIndex = null;
    }

    final selected =
        _selectedIndex != null ? filteredReceipts[_selectedIndex!] : null;
    final dayCount = filteredReceipts.length;
    final dayTotal = filteredReceipts.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    final cashTotal = filteredReceipts
        .where((item) => item.payment.toLowerCase() == 'cash')
        .fold<double>(0, (sum, item) => sum + item.total);
    final cardTotal = filteredReceipts
        .where((item) => item.payment.toLowerCase() == 'card')
        .fold<double>(0, (sum, item) => sum + item.total);

    return Scaffold(
      drawer: const AppDrawerPos(),
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: Container(
        color: const Color(0xFFF4F6FA),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
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
                            items: _availableDates
                                .map(
                                  (d) => DropdownMenuItem<String>(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedDate = value;
                                _selectedIndex = null;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Pick date',
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(_selectedDate) ??
                                  DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked == null) return;
                            final selectedDate = _formatDate(picked);
                            if (_availableDates.contains(selectedDate)) {
                              setState(() {
                                _selectedDate = selectedDate;
                                _selectedIndex = null;
                              });
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No receipt found on $selectedDate',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.edit_calendar_rounded),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Sales Count',
                          value: '$dayCount',
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Day Total',
                          value: '\$${dayTotal.toStringAsFixed(2)}',
                          icon: Icons.attach_money_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Cash Total',
                          value: '\$${cashTotal.toStringAsFixed(2)}',
                          icon: Icons.payments_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Card Total',
                          value: '\$${cardTotal.toStringAsFixed(2)}',
                          icon: Icons.credit_card_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredReceipts.isEmpty
                  ? const Center(
                      child: Text(
                        'No receipts for selected day',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredReceipts.length,
                      itemBuilder: (context, index) {
                        final item = filteredReceipts[index];
                        final selectedTile = index == _selectedIndex;
                        return Card(
                          elevation: 0.6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selectedTile
                                  ? const Color(0xFF3E66C5)
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() => _selectedIndex = index);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            title: Text(
                              '${item.id} • ${item.customer}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${item.dateTime}  •  ${item.payment.toUpperCase()}',
                            ),
                            trailing: Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (selected == null && filteredReceipts.isNotEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  'Tap a receipt to view detail',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (selected != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Receipt Detail ${selected.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close detail',
                          onPressed: () {
                            setState(() => _selectedIndex = null);
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.customer,
                      style: const TextStyle(color: Colors.transparent),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Customer: ${selected.customer}'),
                    Text('Date: ${selected.dateTime}'),
                    Text('Payment: ${selected.payment.toUpperCase()}'),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    const Text(
                      'Services',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    for (final service in selected.services)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('- $service'),
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: \$${selected.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E66C5),
                        ),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
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
                  label,
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

class _ReceiptItem {
  final String id;
  final String customer;
  final String dateTime;
  final List<String> services;
  final double total;
  final String payment;

  const _ReceiptItem({
    required this.id,
    required this.customer,
    required this.dateTime,
    required this.services,
    required this.total,
    required this.payment,
  });

  String get dateOnly => dateTime.split(' ').first;
}
