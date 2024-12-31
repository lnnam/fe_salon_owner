import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:salonapp/constants.dart';
import 'customer.dart'; // Import SchedulePage


class BookingCalendarPage extends StatefulWidget {
  @override
  _BookingCalendarPageState createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage> {
  late BookingService mockBookingService;
  final now = DateTime.now();
  List<DateTimeRange> converted = [];

  @override
  void initState() {
    super.initState();
    mockBookingService = BookingService(
        serviceName: 'Mock Service',
        serviceDuration: 15,
        bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
        bookingStart: DateTime(now.year, now.month, now.day, 9, 0));
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  Future<dynamic> uploadBookingMock(
      {required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
   // print('${newBooking.toJson()} has been uploaded');
    Provider.of<BookingProvider>(context, listen: false).setSchedule(newBooking.toJson());
     Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerPage(), // Navigate to SchedulePage
                            ),
                          );
  }

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    DateTime first = now;
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime second = now.add(const Duration(minutes: 55));
    DateTime third = now.subtract(const Duration(minutes: 240));
    DateTime fourth = now.subtract(const Duration(minutes: 500));
    converted.add(
        DateTimeRange(start: first, end: now.add(const Duration(minutes: 30))));
    converted.add(DateTimeRange(
        start: second, end: second.add(const Duration(minutes: 23))));
    converted.add(DateTimeRange(
        start: third, end: third.add(const Duration(minutes: 15))));
    converted.add(DateTimeRange(
        start: fourth, end: fourth.add(const Duration(minutes: 50))));

    //book whole day example
    converted.add(DateTimeRange(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 0)));
    return converted;
  }

  List<DateTimeRange> generatePauseSlots() {
    return [
      DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 12, 0),
          end: DateTime(now.year, now.month, now.day, 13, 0))
    ];
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(COLOR_PRIMARY);
    return Scaffold(
        appBar: AppBar(
           title: const Text('Booking Calendar',  style: TextStyle(color: Colors.white)),
           backgroundColor: color, // Set app bar color
        ),
        body: Center(
          child: BookingCalendar(
            bookingService: mockBookingService,
            convertStreamResultToDateTimeRanges: convertStreamResultMock,
            getBookingStream: getBookingStreamMock,
            uploadBooking: uploadBookingMock,
            pauseSlots: generatePauseSlots(),
            pauseSlotText: 'LUNCH',
            hideBreakTime: false,
            loadingWidget: const Text('Fetching data...'),
            uploadingWidget: const CircularProgressIndicator(),
            locale: 'en_GB',
            startingDayOfWeek: StartingDayOfWeek.tuesday,
            wholeDayIsBookedWidget:
                const Text('Sorry, for this day everything is booked'),
            //disabledDates: [DateTime(2023, 1, 20)],
            //disabledDays: [6, 7],
          ),
        ),
      );
  }
}