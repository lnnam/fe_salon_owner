import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/customer.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:http/http.dart' as http;
import 'package:salonapp/api/api_manager.dart';



class CustomerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: FutureBuilder<List<Customer>>(
        future: apiManager.ListCustomer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No customers found'));
          } else {
            final customerList = snapshot.data!;
            return Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: customerList.length,
                itemBuilder: (BuildContext context, int index) {
                  Customer customer = customerList[index];
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
                          Provider.of<BookingProvider>(context, listen: false).setCustomerDetails(customer.fullname, customer.email);
                          // Print the customer details to the console
                          print('Selected Customer: ${Provider.of<BookingProvider>(context, listen: false).onbooking.customerName}, ${Provider.of<BookingProvider>(context, listen: false).onbooking.customerEmail}');
                          // Navigate to the next page if needed
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}