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
      print('API Response Data: $data');
      print('API Response Date: ${DateTime.now()}');

      // Handle response - API returns a List containing a Map with customer data
      final List<dynamic> customerList;
      if (data is List && data.isNotEmpty) {
        print('[DEBUG] Response is a List with ${data.length} items');
        // Check if first item is a Map containing all customers
        if (data[0] is Map) {
          print('[DEBUG] First item is a Map, extracting customer values');
          final Map<dynamic, dynamic> customerMap = data[0];
          customerList = customerMap.values.toList();
          print('[DEBUG] Extracted ${customerList.length} customers from Map');
        } else {
          // List of individual customer objects
          customerList = data;
          print('[DEBUG] List contains ${data.length} customer items');
        }
      } else if (data is Map) {
        print('[DEBUG] Response is directly a Map');
        customerList = data.values.toList();
        print('[DEBUG] Extracted ${customerList.length} customers from Map');
      } else {
        throw Exception('Unexpected data format from API: ${data.runtimeType}');
      }

      if (customerList.isNotEmpty) {
        print('[DEBUG] First item type: ${customerList[0].runtimeType}');
        print('[DEBUG] First item: ${customerList[0]}');
      }

      final List<Customer> customers = customerList.where((json) {
        // Filter out metadata objects - they have 'fieldCount', 'affectedRows', etc.
        if (json is! Map<String, dynamic>) return false;
        // Metadata has these fields, real customers have 'fullname' and 'pkey'
        return json.containsKey('fullname') && json.containsKey('pkey');
      }).map((json) {
        final customer = Customer.fromJson(json as Map<String, dynamic>);
        print(
            '[DEBUG] Parsed customer: key=${customer.customerkey}, name=${customer.fullname}, email=${customer.email}, phone=${customer.phone}');
        return customer;
      }).toList();
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
            (c.phone.isNotEmpty && c.phone.toLowerCase().contains(q)) ||
            (c.email.isNotEmpty && c.email.toLowerCase().contains(q));
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
