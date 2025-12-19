import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/customer.dart';
import 'dart:convert';
import 'dart:typed_data';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _loading = true;
  String _search = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await apiManager.fetchFromServer(AppConfig.api_url_customer_list);
      final List<Customer> customers = (data as List)
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filter(String value) {
    setState(() {
      _search = value;
      _filteredCustomers = _customers.where((c) {
        final q = value.toLowerCase();
        return c.fullname.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredCustomers.isEmpty
                        ? const Center(child: Text('No customers found'))
                        : ListView.builder(
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              Uint8List? photoBytes;
                              if (customer.photo != 'Unknown' &&
                                  customer.photo.isNotEmpty) {
                                try {
                                  photoBytes = base64Decode(customer.photo);
                                } catch (_) {
                                  photoBytes = null;
                                }
                              }
                              return ListTile(
                                leading: CircleAvatar(
                                  child: (photoBytes == null)
                                      ? const Icon(Icons.person)
                                      : null,
                                  backgroundImage: (photoBytes != null)
                                      ? MemoryImage(photoBytes)
                                      : null,
                                ),
                                title: Text(customer.fullname),
                                subtitle: Text(
                                    '${customer.phone} | ${customer.email}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        tooltip: 'Add Customer',
      ),
    );
  }
}
