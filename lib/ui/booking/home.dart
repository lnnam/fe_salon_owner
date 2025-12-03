import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/constants.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/ui/common/drawer_booking.dart';
import 'package:salonapp/ui/booking/staff.dart';
import 'package:salonapp/services/helper.dart';
import 'summary.dart'; // Import Home
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';

class BookingHomeScreen extends StatefulWidget {
  const BookingHomeScreen({super.key});

  @override
  _BookingHomeScreenState createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Set editMode to false when home page loads. Use post-frame to avoid
    // calling provider during widget construction.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.resetBooking();
      // Trigger initial load
      bookingProvider.manualRefresh();
      // debug log
      print('[BookingHomeScreen] Initialized, manual refresh triggered');
    });
  }

  Widget _buildDateHeader(DateTime date, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          left: BorderSide(color: color, width: 4.0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, Color color) {
    final isPastLocal = isBookingInPast(booking);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isPastLocal
                ? Colors.grey.withOpacity(0.2)
                : color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: isPastLocal ? Colors.grey[300]! : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: isPastLocal ? Colors.grey[100] : Colors.white,
        child: InkWell(
          onTap: () => safePush(context, SummaryPage(booking: booking)),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPastLocal ? Colors.grey[400] : color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  formatBookingTime(booking.bookingstart),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (booking.createdby?.toLowerCase() != 'salon')
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.language,
                                  color: Colors.white, size: 12),
                            ),
                          if (booking.status.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: _statusColor(booking.status, color)
                                      .withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.status,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.customername,
                        style: TextStyle(
                            color:
                                isPastLocal ? Colors.grey[700] : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.spa,
                              color: isPastLocal
                                  ? Colors.grey[500]
                                  : color.withOpacity(0.7),
                              size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(booking.servicename,
                                  style: TextStyle(
                                      color: isPastLocal
                                          ? Colors.grey[600]
                                          : Colors.black54,
                                      fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: isPastLocal
                                  ? Colors.grey[500]
                                  : color.withOpacity(0.7),
                              size: 16),
                          const SizedBox(width: 4),
                          Text('Staff: ${booking.staffname}',
                              style: TextStyle(
                                  color: isPastLocal
                                      ? Colors.grey[600]
                                      : Colors.black54,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: isPastLocal ? Colors.grey[400] : color, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status, Color defaultColor) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait')) {
      return Colors.orange.shade700;
    }
    if (s.contains('confirm') ||
        s.contains('booked') ||
        s.contains('confirmed')) {
      return Colors.green.shade600;
    }
    if (s.contains('cancel') || s.contains('void')) {
      return Colors.red.shade600;
    }
    if (s.contains('done') || s.contains('completed')) {
      return Colors.blueGrey.shade600;
    }
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(COLOR_PRIMARY);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        actions: [
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  print('[BookingHomeScreen] Manual refresh button tapped');
                  bookingProvider.manualRefresh();
                },
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawerBooking(),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          return StreamBuilder<List<Booking>>(
            stream: bookingProvider.bookingStream,
            builder: (context, snapshot) {
              print('[BookingHomeScreen] StreamBuilder: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, dataLength=${snapshot.data?.length ?? 0}');
              
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No bookings available.'));
              }

              final groupedBookings = _groupBookingsByDate(snapshot.data!);
              final sortedDates = groupedBookings.keys.toList();
              sortedDates.sort((a, b) => a.compareTo(b));

              return Container(
                color: Colors.grey[50],
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final date = sortedDates[index];
                            final bookings = groupedBookings[date]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateHeader(date, color),
                                ...bookings
                                    .map((booking) => _buildBookingCard(booking, color))
                                    .toList(),
                              ],
                            );
                          },
                          childCount: sortedDates.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          safePush(context, const StaffPage());
        },
        backgroundColor: color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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

  static Map<DateTime, List<Booking>> _groupBookingsByDate(
      List<Booking> bookings) {
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

  bool isBookingInPast(Booking booking) {
    final date = DateTime.parse(booking.bookingdate);
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      booking.bookingtime.hour,
      booking.bookingtime.minute,
    );
    return bookingDateTime.isBefore(DateTime.now());
  }
}
