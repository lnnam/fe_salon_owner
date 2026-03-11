import 'package:flutter/material.dart';
import '../../model/service.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  // Example service data
  final List<Service> _services = [
    Service(pkey: 1, name: 'Haircut', price: 25.00, category: 'Hair'),
    Service(pkey: 2, name: 'Hair Wash', price: 10.00, category: 'Hair'),
    Service(pkey: 3, name: 'Hair Color', price: 60.00, category: 'Hair'),
    Service(pkey: 4, name: 'Blow Dry', price: 20.00, category: 'Hair'),
    Service(pkey: 5, name: 'Manicure', price: 30.00, category: 'Nails'),
    Service(pkey: 6, name: 'Pedicure', price: 35.00, category: 'Nails'),
    Service(pkey: 7, name: 'Gel Nails', price: 50.00, category: 'Nails'),
    Service(pkey: 8, name: 'Facial', price: 45.00, category: 'Skin'),
    Service(pkey: 9, name: 'Eyebrow Wax', price: 15.00, category: 'Skin'),
    Service(pkey: 10, name: 'Massage', price: 70.00, category: 'Body'),
    Service(pkey: 11, name: 'Back Massage', price: 55.00, category: 'Body'),
    Service(pkey: 12, name: 'Highlights', price: 80.00, category: 'Hair'),
  ];

  // Cart: service -> quantity
  final Map<int, int> _cart = {};

  double get _total {
    double t = 0;
    _cart.forEach((pkey, qty) {
      final svc = _services.firstWhere((s) => s.pkey == pkey);
      t += svc.price * qty;
    });
    return t;
  }

  List<MapEntry<Service, int>> get _cartItems {
    return _cart.entries.map((e) {
      final svc = _services.firstWhere((s) => s.pkey == e.key);
      return MapEntry(svc, e.value);
    }).toList();
  }

  void _addToCart(Service service) {
    setState(() {
      _cart[service.pkey] = (_cart[service.pkey] ?? 0) + 1;
    });
  }

  void _removeFromCart(Service service) {
    setState(() {
      if ((_cart[service.pkey] ?? 0) <= 1) {
        _cart.remove(service.pkey);
      } else {
        _cart[service.pkey] = _cart[service.pkey]! - 1;
      }
    });
  }

  void _onSave() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    _showPaymentDialog();
  }

  void _showPaymentDialog() {
    final total = _total;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 40, color: Color(0xFF3E66C5)),
              const SizedBox(height: 12),
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E66C5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Cash button
                  Expanded(
                    child: _PaymentOption(
                      icon: Icons.money_rounded,
                      label: 'Cash',
                      color: Colors.green.shade600,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _confirmPayment('Cash', total);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card button
                  Expanded(
                    child: _PaymentOption(
                      icon: Icons.credit_card_rounded,
                      label: 'Card',
                      color: const Color(0xFF3E66C5),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _confirmPayment('Card', total);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPayment(String method, double total) {
    // TODO: send order + payment method to API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paid \$${total.toStringAsFixed(2)} by $method',
        ),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _cart.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: const Color(0xFF3E66C5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Service grid
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final qty = _cart[service.pkey] ?? 0;
                  final selected = qty > 0;
                  return GestureDetector(
                    onTap: () => _addToCart(service),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color:
                            selected ? const Color(0xFF3E66C5) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF3E66C5)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.spa_rounded,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF3E66C5),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${service.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: selected
                                          ? Colors.white70
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (qty > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Cart section
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Cart header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined,
                          color: Color(0xFF3E66C5)),
                      const SizedBox(width: 8),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (_cart.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _cart.clear()),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),

                // Cart items list
                if (_cartItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'No services selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, i) {
                        final entry = _cartItems[i];
                        final svc = entry.key;
                        final qty = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  svc.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () => _removeFromCart(svc),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () => _addToCart(svc),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '\$${(svc.price * qty).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const Divider(height: 1),

                // Total + Save button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E66C5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E66C5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF3E66C5)),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
