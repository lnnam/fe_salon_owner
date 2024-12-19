import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/service.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/provider/booking.provider.dart';

class ServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
      ),
      body: FutureBuilder<List<Service>>(
        future: apiManager.ListServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No services found'));
          } else {
            final serviceList = snapshot.data!;
            return Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: serviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  Service service = serviceList[index];
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
                        title: Text(
                          service.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Price: \$${service.price}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Handle tap on service
                          Provider.of<BookingProvider>(context, listen: false).setService(service.pkey);
                          // Print the service name to the console
                          print('Selected Service: ${Provider.of<BookingProvider>(context, listen: false).onbooking.servicekey}');
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