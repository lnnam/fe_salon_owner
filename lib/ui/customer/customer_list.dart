import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/customer.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:salonapp/api/http/customer.dart';
import 'package:salonapp/ui/customer/customer_form.dart';
import 'package:salonapp/ui/customer/customer_detail.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Customer> _allCustomers = []; // All customers for search
  List<Customer> _displayedCustomers = []; // Customers being displayed
  List<Customer> _filteredCustomers = []; // Filtered results
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String _searchQuery = '';
  final int _pageSize = 5;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  // Upcoming birthdays
  List<Customer> _upcomingBirthdays = [];
  bool _loadingBirthdays = false;
  String? _birthdaysError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCustomers();
    _fetchUpcomingBirthdays();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when user scrolls near the bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _searchQuery.isEmpty) {
      _loadMore();
    }
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
        // Check if first item is a Map containing all customers
        if (data[0] is Map) {
          final Map<dynamic, dynamic> customerMap = data[0];
          customerList = customerMap.values.toList();
        } else {
          // List of individual customer objects
          customerList = data;
        }
      } else if (data is Map) {
        customerList = data.values.toList();
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

        return customer;
      }).toList();

      // Sort by key descending to get latest customers first
      customers.sort((a, b) => b.customerkey.compareTo(a.customerkey));

      setState(() {
        _allCustomers = customers;
        _currentPage = 0;
        _displayedCustomers = _getPagedCustomers(0);
        _filteredCustomers = _displayedCustomers;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Customer> _getPagedCustomers(int page) {
    final start = page * _pageSize;
    final end = start + _pageSize;
    if (start >= _allCustomers.length) return [];
    return _allCustomers.sublist(start, end.clamp(0, _allCustomers.length));
  }

  Future<void> _loadMore() async {
    if (_searchQuery.isNotEmpty) return; // Don't paginate during search

    setState(() {
      _loadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final nextPage = _currentPage + 1;
    final moreCustomers = _getPagedCustomers(nextPage);

    if (moreCustomers.isNotEmpty) {
      setState(() {
        _currentPage = nextPage;
        _displayedCustomers.addAll(moreCustomers);
        _filteredCustomers = _displayedCustomers;
        _loadingMore = false;
      });
    } else {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void _filter(String value) {
    setState(() {
      _searchQuery = value;
      if (value.isEmpty) {
        // Show first page of all customers
        _currentPage = 0;
        _displayedCustomers = _getPagedCustomers(0);
        _filteredCustomers = _displayedCustomers;
      } else {
        // Search all customers
        _filteredCustomers = _allCustomers.where((c) {
          final q = value.toLowerCase();
          return c.fullname.toLowerCase().contains(q) ||
              (c.phone.isNotEmpty && c.phone.toLowerCase().contains(q)) ||
              (c.email.isNotEmpty && c.email.toLowerCase().contains(q));
        }).toList();
      }
    });
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.fullname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final customerApi = CustomerApi(apiManager);
      final success = await customerApi.deleteCustomer(customer.customerkey);

      if (!mounted) return;

      if (success) {
        // Remove from lists
        setState(() {
          _allCustomers
              .removeWhere((c) => c.customerkey == customer.customerkey);
          _displayedCustomers
              .removeWhere((c) => c.customerkey == customer.customerkey);
          _filteredCustomers
              .removeWhere((c) => c.customerkey == customer.customerkey);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.fullname} deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete customer'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openCustomerDetail(Customer customer) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(customer: customer),
      ),
    );

    if (result == true) {
      // Refresh the list after customer is updated
      _fetchCustomers();
    }
  }

  Future<void> _fetchUpcomingBirthdays() async {
    setState(() {
      _loadingBirthdays = true;
      _birthdaysError = null;
    });
    try {
      final data = await apiManager.fetchFromServer(
          '${AppConfig.api_url}/api/customer/upcoming-birthday');
      print('[Birthdays] API Response: $data');
      print('[Birthdays] Response type: ${data.runtimeType}');

      final List<dynamic> birthdayList;
      if (data is List && data.isNotEmpty) {
        print('[Birthdays] Response is a List with ${data.length} items');
        print('[Birthdays] First item type: ${data[0].runtimeType}');
        print('[Birthdays] First item: ${data[0]}');
        // List of individual customer objects
        birthdayList = data;
        print('[Birthdays] List contains ${data.length} customer items');
      } else if (data is Map) {
        print('[Birthdays] Response is directly a Map');
        print('[Birthdays] Map keys: ${data.keys}');
        print('[Birthdays] Map values count: ${data.values.length}');
        // If it's a single map with customer data, wrap it in a list
        if (data.containsKey('pkey') || data.containsKey('fullname')) {
          print(
              '[Birthdays] Map contains customer data, treating as single customer');
          birthdayList = [data];
        } else {
          // Map of customers
          birthdayList = data.values.toList();
        }
      } else {
        print('[Birthdays] Response is neither List nor Map');
        birthdayList = [];
      }

      final customers = birthdayList.map((customer) {
        print('[Birthdays] Parsing customer: $customer');
        print('[Birthdays] Customer type: ${customer.runtimeType}');
        // Ensure customer is a Map before parsing
        if (customer is Map<String, dynamic>) {
          print('[Birthdays] Customer fields: ${customer.keys}');
          return Customer.fromJson(customer);
        } else if (customer is Map) {
          print('[Birthdays] Casting Map to Map<String, dynamic>');
          return Customer.fromJson(customer.cast<String, dynamic>());
        } else {
          print(
              '[Birthdays] WARNING: Customer is not a Map, type: ${customer.runtimeType}, value: $customer');
          // Return empty customer or skip
          return Customer(
            customerkey: 0,
            fullname: 'Unknown',
            email: 'Unknown',
            phone: 'Unknown',
            photo: 'Unknown',
          );
        }
      }).toList();

      setState(() {
        _upcomingBirthdays = customers;
        _loadingBirthdays = false;
      });

      print(
          '[Birthdays] Total upcoming birthdays: ${_upcomingBirthdays.length}');
      for (var i = 0; i < _upcomingBirthdays.length; i++) {
        print(
            '[Birthdays] Customer $i: ${_upcomingBirthdays[i].fullname} - ${_upcomingBirthdays[i].birthday}');
      }
    } catch (e) {
      setState(() {
        _birthdaysError = e.toString();
        _loadingBirthdays = false;
      });
      print('[Birthdays] Error: $e');
      print('[Birthdays] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _addCustomer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerFormPage(customer: null),
      ),
    );

    if (result == true) {
      // Refresh the list after successful add
      _fetchCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Customers'),
            Text(
              'Total: ${_allCustomers.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Name, phone, or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Search results: ${_filteredCustomers.length} found',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Customer List Section - Only show when searching
                  if (_searchQuery.isNotEmpty)
                    SizedBox(
                      height: 400,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(child: Text(_error!))
                              : _filteredCustomers.isEmpty
                                  ? const Center(
                                      child: Text('No customers found'))
                                  : ListView.builder(
                                      controller: _scrollController,
                                      itemCount: _filteredCustomers.length +
                                          (_loadingMore && _searchQuery.isEmpty
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        // Loading indicator at the bottom
                                        if (index ==
                                            _filteredCustomers.length) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final customer =
                                            _filteredCustomers[index];
                                        Uint8List? photoBytes;
                                        if (customer.photo != 'Unknown' &&
                                            customer.photo.isNotEmpty) {
                                          try {
                                            photoBytes =
                                                base64Decode(customer.photo);
                                          } catch (_) {
                                            photoBytes = null;
                                          }
                                        }
                                        return ListTile(
                                          leading: CircleAvatar(
                                            child: (photoBytes == null)
                                                ? const Icon(Icons.person)
                                                : null,
                                            backgroundImage:
                                                (photoBytes != null)
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
                                                icon: const Icon(Icons.delete),
                                                onPressed: () =>
                                                    _deleteCustomer(customer),
                                              ),
                                            ],
                                          ),
                                          onTap: () =>
                                              _openCustomerDetail(customer),
                                        );
                                      },
                                    ),
                    ),

                  // Upcoming Birthdays Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Birthdays',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingBirthdays)
                          const Center(child: CircularProgressIndicator())
                        else if (_birthdaysError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _birthdaysError!,
                              style: TextStyle(color: Colors.orange[700]),
                            ),
                          )
                        else if (_upcomingBirthdays.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Text(
                              'No upcoming birthdays',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _upcomingBirthdays.length,
                            itemBuilder: (context, index) {
                              final customer = _upcomingBirthdays[index];
                              Uint8List? photoBytes;
                              if (customer.photo != 'Unknown' &&
                                  customer.photo.isNotEmpty) {
                                try {
                                  photoBytes = base64Decode(customer.photo);
                                } catch (_) {
                                  photoBytes = null;
                                }
                              }
                              
                              // Check if birthday is today
                              bool isBirthdayToday = false;
                              if (customer.birthday.isNotEmpty) {
                                try {
                                  final birthdayDate = DateTime.parse(customer.birthday);
                                  final today = DateTime.now();
                                  isBirthdayToday = birthdayDate.month == today.month && 
                                                   birthdayDate.day == today.day;
                                } catch (e) {
                                  print('[Birthdays] Error parsing birthday: ${customer.birthday} - $e');
                                }
                              }
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isBirthdayToday ? Colors.pink.shade100 : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: (photoBytes == null)
                                        ? const Icon(Icons.person)
                                        : null,
                                    backgroundImage: (photoBytes != null)
                                        ? MemoryImage(photoBytes)
                                        : null,
                                  ),
                                  title: Text(
                                    customer.fullname,
                                    style: isBirthdayToday 
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                        )
                                      : null,
                                  ),
                                  subtitle:
                                      Text('Birthday: ${customer.birthday}'),
                                  trailing: Icon(
                                    Icons.cake,
                                    color: isBirthdayToday ? Colors.pink : Colors.pink,
                                  ),
                                  onTap: () => _openCustomerDetail(customer),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
        tooltip: 'Add Customer',
      ),
    );
  }
}
