import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/customer.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/services/helper.dart';
import 'Summary.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customerList = [];
  List<Customer> _filteredCustomerList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCustomers);
    _fetchCustomers();
    // Pause booking auto-refresh when opening this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.pauseAutoRefresh();
      print('[CustomerPage] Opened, auto-refresh paused');
    });
  }

  @override
  void dispose() {
    // Resume booking auto-refresh when closing this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resumeAutoRefresh();
    print('[CustomerPage] Closed, auto-refresh resumed');
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCustomers() async {
    try {
      List<Customer> customers = await apiManager.ListCustomer();
      if (!mounted) return;
      setState(() {
        _customerList = customers;
        _filteredCustomerList = customers;
      });
    } catch (error) {
      // error fetching customers
    }
  }

  void _filterCustomers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomerList = _customerList.where((customer) {
        return customer.fullname.toLowerCase().contains(query) ||
            customer.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final dobController = TextEditingController();
    bool isLoading = false;

    // Ensure booking refresh is paused while dialog is open
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.pauseAutoRefresh();
    print('[CustomerPage] Dialog opened, booking refresh paused');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setState) {
            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Customer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            dobController.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Resume booking refresh when closing dialog
                                    final bookingProvider =
                                        Provider.of<BookingProvider>(context,
                                            listen: false);
                                    bookingProvider.resumeAutoRefresh();
                                    print(
                                        '[CustomerPage] Dialog closed, booking refresh resumed');
                                    Navigator.of(dialogContext).pop();
                                  },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (nameController.text.isEmpty ||
                                        phoneController.text.isEmpty) {
                                      showAlertDialog(context, 'Error',
                                          'Please fill in all required fields');
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      final result =
                                          await apiManager.AddCustomer(
                                        name: nameController.text,
                                        email: emailController.text,
                                        phone: phoneController.text,
                                        dob: dobController.text.isEmpty
                                            ? ''
                                            : dobController.text,
                                      );

                                      setState(() {
                                        isLoading = false;
                                      });

                                      if (result != null) {
                                        // Parse the result to ensure correct format
                                        final customerData = {
                                          'customerkey': result['pkey'] ??
                                              result['customerkey'] ??
                                              0,
                                          'fullname': result['fullname'] ??
                                              nameController.text,
                                          'email': result['email'] ??
                                              emailController.text,
                                          'phone': result['phone'] ??
                                              phoneController.text,
                                          'photo': result['photobase64'] ??
                                              result['photo'] ??
                                              '',
                                        };

                                        // Close the dialog first
                                        if (mounted) {
                                          // Resume booking refresh when closing dialog
                                          final bookingProvider =
                                              Provider.of<BookingProvider>(
                                                  context,
                                                  listen: false);
                                          bookingProvider.resumeAutoRefresh();
                                          print(
                                              '[CustomerPage] Dialog closed after customer add, booking refresh resumed');

                                          Navigator.of(dialogContext).pop();

                                          // Set the new customer in the provider
                                          Provider.of<BookingProvider>(context,
                                                  listen: false)
                                              .setCustomerDetails(customerData);

                                          // Navigate to the summary page
                                          safePush(
                                            context,
                                            const SummaryPage(),
                                          );
                                        }
                                      } else {
                                        showAlertDialog(context, 'Error',
                                            'Failed to add customer. Please try again.');
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showAlertDialog(context, 'Error',
                                          'An error occurred: $e');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Add Customer',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Customers',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _buildCustomerList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Walk-in customer logic
                      final walkInCustomer = {
                        'customerkey': 1,
                        'fullname': 'Walk-in Customer',
                        'email': '',
                        'phone': '',
                        'photo': '',
                      };
                      Provider.of<BookingProvider>(context, listen: false)
                          .setCustomerDetails(walkInCustomer);
                      safePush(
                        context,
                        const SummaryPage(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Walk In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAddCustomerDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'New Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return _filteredCustomerList.isEmpty
        ? const Center(child: Text('No customers found'))
        : ListView.builder(
            itemCount: _filteredCustomerList.length,
            itemBuilder: (BuildContext context, int index) {
              Customer customer = _filteredCustomerList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<BookingProvider>(context, listen: false)
                        .setCustomerDetails(customer.toJson());
                    safePush(
                      context,
                      const SummaryPage(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: getImage(customer.photo),
                        child: getImage(customer.photo) == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        customer.fullname,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Email: ${customer.email}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
