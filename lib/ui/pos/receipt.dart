import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/ui/common/drawer_pos.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  String _selectedDate = _formatDate(DateTime.now());
  int _selectedPage = 1;
  final int _pageLimit = 20;

  bool _isLoading = true;
  String? _error;
  _ReceiptResponse? _response;

  int? _selectedIndex;

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void initState() {
    super.initState();
    _loadReceipts(date: _selectedDate, page: 1);
  }

  Future<void> _loadReceipts({required String date, required int page}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await apiManager.getPosReceipts(
        date: date,
        page: page,
        limit: _pageLimit,
      );

      final parsed = _ReceiptResponse.fromJson(data);
      setState(() {
        _response = parsed;
        _selectedDate = parsed.date.isEmpty ? date : parsed.date;
        _selectedPage = parsed.pagination.page;
        _selectedIndex = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final date = _formatDate(picked);
    await _loadReceipts(date: date, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final receipts = _response?.receipts ?? <_ReceiptItem>[];
    final selected = _selectedIndex != null && _selectedIndex! < receipts.length
        ? receipts[_selectedIndex!]
        : null;

    final dayCount = receipts.length;
    final dayTotal = receipts.fold<double>(0, (sum, item) => sum + item.total);
    final cashTotal = receipts
        .where((item) => item.paymentMethod.toLowerCase() == 'cash')
        .fold<double>(0, (sum, item) => sum + item.total);
    final cardTotal = receipts
        .where((item) => item.paymentMethod.toLowerCase() == 'card')
        .fold<double>(0, (sum, item) => sum + item.total);

    return Scaffold(
      drawer: const AppDrawerPos(),
      appBar: AppBar(
        title: const Text('Receipt'),
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
                            onPressed: () => _loadReceipts(
                              date: _selectedDate,
                              page: _selectedPage,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Pick date',
                                    onPressed: _pickDate,
                                    icon:
                                        const Icon(Icons.edit_calendar_rounded),
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
                        child: receipts.isEmpty
                            ? const Center(
                                child: Text(
                                  'No receipts for selected day',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: receipts.length,
                                itemBuilder: (context, index) {
                                  final item = receipts[index];
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      title: Text(
                                        '${item.receiptNo} • ${item.serviceName}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        '${item.dateactivated}  •  ${item.paymentMethod}',
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
                      if (_response != null &&
                          _response!.pagination.totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectedPage > 1
                                      ? () => _loadReceipts(
                                            date: _selectedDate,
                                            page: _selectedPage - 1,
                                          )
                                      : null,
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  label: const Text('Prev'),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Page ${_response!.pagination.page}/${_response!.pagination.totalPages}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectedPage <
                                          _response!.pagination.totalPages
                                      ? () => _loadReceipts(
                                            date: _selectedDate,
                                            page: _selectedPage + 1,
                                          )
                                      : null,
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  label: const Text('Next'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (selected == null && receipts.isNotEmpty)
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
                                      'Receipt Detail ${selected.receiptNo}',
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
                              const SizedBox(height: 6),
                              Text('PKey: ${selected.pkey}'),
                              Text('Service: ${selected.serviceName}'),
                              Text('Receipt No: ${selected.receiptNo}'),
                              Text('Date: ${selected.dateactivated}'),
                              Text('Payment: ${selected.paymentMethod}'),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              const Text(
                                'Services',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              if (selected.services.isEmpty)
                                Row(
                                  children: [
                                    Expanded(child: Text(selected.serviceName)),
                                    Text(
                                      '\$${selected.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                for (final s in selected.services)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(s.name)),
                                        Text(
                                          '\$${s.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
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

class _ReceiptResponse {
  final String date;
  final _ReceiptPagination pagination;
  final List<_ReceiptItem> receipts;

  const _ReceiptResponse({
    required this.date,
    required this.pagination,
    required this.receipts,
  });

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  factory _ReceiptResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['receipts'] as List<dynamic>? ?? [];
    return _ReceiptResponse(
      date: (json['date'] ?? '').toString(),
      pagination: _ReceiptPagination.fromJson(
          Map<String, dynamic>.from(json['pagination'] ?? {})),
      receipts: raw
          .whereType<Map>()
          .map((e) => _ReceiptItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class _ReceiptPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const _ReceiptPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory _ReceiptPagination.fromJson(Map<String, dynamic> json) {
    return _ReceiptPagination(
      page: _ReceiptResponse._toInt(json['page']),
      limit: _ReceiptResponse._toInt(json['limit']),
      total: _ReceiptResponse._toInt(json['total']),
      totalPages: _ReceiptResponse._toInt(json['total_pages']),
    );
  }
}

class _ReceiptItem {
  final int pkey;
  final String receiptNo;
  final String serviceName;
  final List<_ReceiptService> services;
  final String paymentMethod;
  final double total;
  final String dateactivated;

  const _ReceiptItem({
    required this.pkey,
    required this.receiptNo,
    required this.serviceName,
    required this.services,
    required this.paymentMethod,
    required this.total,
    required this.dateactivated,
  });

  factory _ReceiptItem.fromJson(Map<String, dynamic> json) {
    final servicesRaw = (json['services'] as List<dynamic>? ?? []);
    return _ReceiptItem(
      pkey: _ReceiptResponse._toInt(json['pkey']),
      receiptNo: (json['receipt_no'] ?? '').toString(),
      serviceName: (json['service_name'] ??
              json['servicename'] ??
              json['customer_name'] ??
              '')
          .toString(),
      services: servicesRaw
          .whereType<Map>()
          .map((e) => _ReceiptService.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      total: _ReceiptResponse._toDouble(json['total']),
      dateactivated: (json['dateactivated'] ?? '').toString(),
    );
  }
}

class _ReceiptService {
  final String name;
  final double price;

  const _ReceiptService({
    required this.name,
    required this.price,
  });

  factory _ReceiptService.fromJson(Map<String, dynamic> json) {
    return _ReceiptService(
      name: (json['name'] ?? '').toString(),
      price: _ReceiptResponse._toDouble(json['price']),
    );
  }
}
