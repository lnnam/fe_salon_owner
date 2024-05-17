import 'package:flutter/material.dart';

class StaffPage extends StatelessWidget {
  // Dummy list of staff members (replace with your actual data)
  final List<StaffMember> staffList = [
    StaffMember(name: 'John Doe', imageUrl: 'assets/john_doe.jpg'),
    StaffMember(name: 'Jane Smith', imageUrl: 'assets/jane_smith.jpg'),
    StaffMember(name: 'Alice Johnson', imageUrl: 'assets/alice_johnson.jpg'),
    // Add more staff members as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff'),
      ),
      body: Container(
        color: Colors.white, // White background for the Scaffold
        child: ListView.builder(
          itemCount: staffList.length,
          itemBuilder: (BuildContext context, int index) {
            StaffMember staffMember = staffList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background for the container
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(staffMember.imageUrl),
                  ),
                  title: Text(
                    staffMember.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Position: Staff Member',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]), // Adjust subtitle color
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle tap on staff member
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Model class to represent a staff member
class StaffMember {
  final String name;
  final String imageUrl;

  StaffMember({
    required this.name,
    required this.imageUrl,
  });
}
