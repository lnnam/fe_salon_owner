import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/constants.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/ui/common/drawer_booking.dart';
import 'package:salonapp/ui/booking/staff.dart';
import 'package:salonapp/services/helper.dart';

class BookingHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Color(COLOR_PRIMARY);
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
      drawer: AppDrawerBooking(),
      body: FutureBuilder<List<Booking>>(
        future: apiManager.ListBooking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings available.'));
          } else {
            final groupedBookings = _groupBookingsByDate(snapshot.data!);
            final sortedDates = groupedBookings.keys.toList();
            sortedDates.sort((a, b) => a.compareTo(b));

            return ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final bookings = groupedBookings[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: color.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Column(
                      children: bookings.map((booking) {
                        ImageProvider imageProvider;
                        try {
                          imageProvider = getImage(booking.customerphoto) ??
                              AssetImage('assets/default_avatar.png');
                        } catch (e) {
                          print('Error loading image: $e');
                          imageProvider = AssetImage('assets/default_avatar.png');
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          elevation: 4.0,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              backgroundImage: imageProvider,
                              child: imageProvider is AssetImage ? Icon(Icons.person) : null,
                            ),
                            title: Text(
                              '${booking.bookingtime}: ${booking.customername}, ${booking.servicename}, Staff: ${booking.staffname}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Number of Visits: 10, Created on: ${booking.created_datetime}',
                              style: TextStyle(
                                color: color,
                              ),
                            ),
                            onTap: () {
                              // Handle onTap event
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StaffPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: color,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Log',
          ),
        ],
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  static Map<DateTime, List<Booking>> _groupBookingsByDate(List<Booking> bookings) {
    Map<DateTime, List<Booking>> groupedBookings = {};
    for (var booking in bookings) {
      final date = DateTime.parse(booking.bookingdate);
      if (groupedBookings.containsKey(date)) {
        groupedBookings[date]!.add(booking);
      } else {
        groupedBookings[date] = [booking];
      }
    }
    return groupedBookings;
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM yyyy').format(dateTime);
  }
}
