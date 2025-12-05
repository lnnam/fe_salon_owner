import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/constants.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/ui/common/drawer_booking.dart';
import 'package:salonapp/ui/booking/staff.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'summary.dart'; // Import Home
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';

class BookingHomeScreen extends StatefulWidget {
  const BookingHomeScreen({super.key});

  @override
  _BookingHomeScreenState createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen>
    with WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  int _todayCount = 0;
  int _weekCount = 0;
  int _logCount = 0;
  int _pendingCount = 0;
  bool _isLogView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set editMode to false when home page loads. Use post-frame to avoid
    // calling provider during widget construction.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.resetBooking();
      // Start auto-refresh polling only on this page
      bookingProvider.startAutoRefresh();
      // Load initial counts
      _loadInitialCounts(bookingProvider);
      // debug log
      print('[BookingHomeScreen] Initialized, auto-refresh started');
    });
  }

  Future<void> _loadInitialCounts(BookingProvider bookingProvider) async {
    try {
      // Load today bookings count
      final today = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(today);
      final todayBookings = await apiManager.ListBooking(opt: formattedDate);

      // Load week bookings count
      final weekBookings = await apiManager.ListBooking(opt: 'thisweek');

      // Load log bookings count
      final logBookings = await apiManager.ListBooking(opt: 'new');

      // Load pending bookings count
      final pendingBookings = await apiManager.ListBooking(opt: 'pending');

      if (mounted) {
        setState(() {
          _todayCount = todayBookings.length;
          _weekCount = weekBookings.length;
          _logCount = logBookings.length;
          _pendingCount = pendingBookings.length;
        });
      }
      print(
          '[BookingHomeScreen] Counts loaded - Today: $_todayCount, Week: $_weekCount, Log: $_logCount, Pending: $_pendingCount');
    } catch (e) {
      print('[BookingHomeScreen] Error loading counts: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App is paused or detached, pause polling
      bookingProvider.pauseAutoRefresh();
      print('[BookingHomeScreen] App lifecycle: $state, auto-refresh paused');
    } else if (state == AppLifecycleState.resumed) {
      // App is resumed, resume polling
      bookingProvider.resumeAutoRefresh();
      print('[BookingHomeScreen] App lifecycle: resumed, auto-refresh resumed');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop auto-refresh when leaving this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.stopAutoRefresh();
    print('[BookingHomeScreen] Disposed, auto-refresh stopped');
    super.dispose();
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
          onTap: () {
            // Log booking selection
            print(
                '═════════════════════════════════════════════════════════════');
            print('[BookingHomeScreen] Booking Tapped - Navigating to Summary');
            print('  - Booking Key: ${booking.pkey}');
            print('  - Customer: ${booking.customername}');
            print('  - Service: ${booking.servicename}');
            print('  - Staff: ${booking.staffname}');
            print('  - Status: ${booking.status}');
            print('  - Booking Time: ${booking.bookingstart}');
            print(
                '═════════════════════════════════════════════════════════════');
            safePush(context, SummaryPage(booking: booking));
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      Row(
                        children: [
                          Icon(Icons.person,
                              color: isPastLocal
                                  ? Colors.grey[500]
                                  : color.withOpacity(0.7),
                              size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.customername,
                              style: TextStyle(
                                  color: isPastLocal
                                      ? Colors.grey[600]
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                          Expanded(
                            child: Text('Staff: ${booking.staffname}',
                                style: TextStyle(
                                    color: isPastLocal
                                        ? Colors.grey[600]
                                        : Colors.black54,
                                    fontSize: 13)),
                          ),
                          if (booking.note.isNotEmpty) ...[
                            Icon(Icons.note,
                                color: isPastLocal
                                    ? Colors.grey[500]
                                    : color.withOpacity(0.7),
                                size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Note: ${booking.note}',
                                style: TextStyle(
                                    color: isPastLocal
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              color: isPastLocal
                                  ? Colors.grey[500]
                                  : color.withOpacity(0.7),
                              size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Created on: ${_formatSchedule(booking.datetimebooking)}',
                              style: TextStyle(
                                  color: isPastLocal
                                      ? Colors.grey[600]
                                      : Colors.black54,
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_forward_ios,
                      color: isPastLocal ? Colors.grey[400] : color, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSchedule(DateTime dateTime) {
    return DateFormat('HH:mm, dd-MM-yyyy').format(dateTime);
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

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No bookings available.'));
              }

              // If in log view, show list without grouping by date
              if (_isLogView) {
                return Container(
                  color: Colors.grey[50],
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final booking = snapshot.data![index];
                              return _buildBookingCard(booking, color);
                            },
                            childCount: snapshot.data!.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Otherwise, group by date (for other views)
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
                                    .map((booking) =>
                                        _buildBookingCard(booking, color))
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: 'Today ($_todayCount)',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.view_week),
            label: 'Week ($_weekCount)',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: 'Log ($_logCount)',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.hourglass_bottom),
            label: 'Pending ($_pendingCount)',
          ),
        ],
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          _handleBottomNavTap(index);
        },
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
      // Normalize to midnight to group same-day bookings together
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (groupedBookings.containsKey(normalizedDate)) {
        groupedBookings[normalizedDate]!.add(booking);
      } else {
        groupedBookings[normalizedDate] = [booking];
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

  void _handleBottomNavTap(int index) {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    // Stop auto-refresh when bottom menu is clicked
    bookingProvider.stopAutoRefresh();
    print('[BookingHomeScreen] Auto-refresh stopped after bottom menu click');

    switch (index) {
      case 0:
        // Find - Show date picker
        print('[BookingHomeScreen] Find tab tapped');
        _showDatePickerForFind(bookingProvider);
        break;
      case 1:
        // Today
        print('[BookingHomeScreen] Today tab tapped');
        _loadTodayBookings(bookingProvider);
        break;
      case 2:
        // Week
        print('[BookingHomeScreen] Week tab tapped');
        _loadWeekBookings(bookingProvider);
        break;
      case 3:
        // Log
        print('[BookingHomeScreen] Log tab tapped');
        _loadLogBookings(bookingProvider);
        break;
      case 4:
        // Pending
        print('[BookingHomeScreen] Pending tab tapped');
        _loadPendingBookings(bookingProvider);
        break;
    }
  }

  Future<void> _showDatePickerForFind(BookingProvider bookingProvider) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      print('[BookingHomeScreen] Date picked for Find: $formattedDate');
      setState(() {
        _isLogView = false;
      });
      bookingProvider.loadBookingsWithDate(formattedDate);
    } else {
      print('[BookingHomeScreen] Date picker cancelled');
      // Reset to index -1 to deselect the Find button
      setState(() {
        _selectedNavIndex = -1;
      });
    }
  }

  void _loadTodayBookings(BookingProvider bookingProvider) {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(today);
    print('[BookingHomeScreen] Loading bookings for today: $formattedDate');
    setState(() {
      _isLogView = false;
    });
    bookingProvider.loadBookingsWithDate(formattedDate);
  }

  void _loadWeekBookings(BookingProvider bookingProvider) {
    print('[BookingHomeScreen] Loading bookings for this week');
    setState(() {
      _isLogView = false;
    });
    bookingProvider.loadBookingsWithOption('thisweek');
  }

  void _loadLogBookings(BookingProvider bookingProvider) {
    print('[BookingHomeScreen] Loading new bookings (log)');
    setState(() {
      _isLogView = true;
    });
    bookingProvider.loadBookingsWithOption('new');
  }

  void _loadPendingBookings(BookingProvider bookingProvider) {
    print('[BookingHomeScreen] Loading pending bookings');
    setState(() {
      _isLogView = false;
    });
    bookingProvider.loadBookingsWithOption('pending');
  }
}
