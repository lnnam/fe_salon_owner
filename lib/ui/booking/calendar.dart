import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';

class BookingCalendarPage extends StatelessWidget {
  final List<Booking> bookings = [
    Booking(DateTime.now(), DateTime.now().add(Duration(days: 2))),
    Booking(DateTime.now().add(Duration(days: 5)), DateTime.now().add(Duration(days: 7))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Calendar Page'),
      ),
      body: Center(
        child: BookingCalendar(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
          bookingService: _bookingService,
          onDateChange: (date) {
            print('Selected date: $date');
          },
          onEventTap: (event) {
            print('Tapped event: $event');
          },
          onMonthChange: (month) {
            print('Month changed: $month');
          },
          onRangeSelected: (range) {
            print('Selected range: $range');
          },
          dayOfWeekStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Booking> _bookingService(DateTime start, DateTime end) {
    // Replace this with your own logic to fetch bookings within the specified range
    return bookings.where((booking) => booking.start.isAfter(start) && booking.end.isBefore(end)).toList();
  }
}

class Booking {
  final DateTime start;
  final DateTime end;

  Booking(this.start, this.end);
}
