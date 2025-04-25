import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/customer.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/services/helper.dart';
import 'dart:convert';
import 'Summary.dart';
import 'package:salonapp/model/booking.dart';


class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  TextEditingController _searchController = TextEditingController();
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
      setState(() {
        _customerList = customers;
        _filteredCustomerList = customers;
      });
    } catch (error) {
      print('Error fetching customers: $error');
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
    );
  }

  Widget _buildCustomerList() {
    return _filteredCustomerList.isEmpty
        ? Center(child: Text('No customers found'))
        : ListView.builder(
            itemCount: _filteredCustomerList.length,
            itemBuilder: (BuildContext context, int index) {
              Customer customer = _filteredCustomerList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: getImage(customer.photo),
                      child: getImage(customer.photo) == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      customer.fullname,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Email: ${customer.email}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Set the selected customer when a customer name is clicked
                      Provider.of<BookingProvider>(context, listen: false).setCustomerDetails(customer.toJson());
                       Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SummaryPage(), // Navigate to SchedulePage
                            ),
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