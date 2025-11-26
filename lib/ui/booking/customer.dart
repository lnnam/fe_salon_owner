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
  }

  @override
  void dispose() {
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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Customer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        labelText: 'Email *',
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            showAlertDialog(context, 'Error',
                                'Please fill in all required fields');
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final result = await apiManager.AddCustomer(
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
                                'fullname':
                                    result['fullname'] ?? nameController.text,
                                'email':
                                    result['email'] ?? emailController.text,
                                'phone':
                                    result['phone'] ?? phoneController.text,
                                'photo': result['photobase64'] ??
                                    result['photo'] ??
                                    '',
                              };

                              // formatted customer data prepared

                              // Close the dialog first
                              Navigator.of(dialogContext).pop();

                              // Use the original context (from CustomerPage) to set provider and navigate
                              if (context.mounted) {
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
                            showAlertDialog(
                                context, 'Error', 'An error occurred: $e');
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
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
                    onTap: () {
                      // Set the selected customer when a customer name is clicked
                      Provider.of<BookingProvider>(context, listen: false)
                          .setCustomerDetails(customer.toJson());
                      safePush(
                        context,
                        const SummaryPage(),
                      );
                      // Print the customer details to the console
                      // Navigate to the next page if needed
                    },
                  ),
                ),
              );
            },
          );
  }
}
