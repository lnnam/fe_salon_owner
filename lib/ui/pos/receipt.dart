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
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selected = _receipts[_selectedIndex];
    final todayCount = _receipts.length;
    final todayTotal = _receipts.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

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
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Today Sales',
                      value: '$todayCount',
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Today Total',
                      value: '\$${todayTotal.toStringAsFixed(2)}',
                      icon: Icons.attach_money_rounded,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _receipts.length,
                itemBuilder: (context, index) {
                  final item = _receipts[index];
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
                      onTap: () => setState(() => _selectedIndex = index),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      title: Text(
                        '${item.id} • ${item.customer}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                  Text(
                    'Receipt Detail ${selected.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}
