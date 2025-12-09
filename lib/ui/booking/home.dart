import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:salonapp/constants.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/ui/common/drawer_booking.dart';
import 'package:salonapp/ui/booking/staff.dart';
import 'summary.dart';

class BookingHomeScreen extends StatefulWidget {
  final String? initialView;

  const BookingHomeScreen({super.key, this.initialView});

  @override
  State<BookingHomeScreen> createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen> {
  int _selectedNavIndex = 0;
  bool _isLogView = false;

  int _todayCount = 0;
  int _weekCount = 0;
  int _monthCount = 0;
  int _logCount = 0;
  int _pendingCount = 0;

  StreamSubscription<List<Booking>>? _bookingSub;

  static const _primaryColor = Color(COLOR_PRIMARY);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);

      bookingProvider.resetBooking();

      _bookingSub ??= bookingProvider.bookingStream.listen((list) {
        if (!mounted) return;
        final opt = bookingProvider.currentViewOption;
        if (opt == null) return;
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

        void _maybeUpdateCount(int oldValue, void Function() update) {
          if (oldValue != list.length && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(update);
            });
          }
        }

        switch (opt) {
          case 'thismonth':
            _maybeUpdateCount(_monthCount, () => _monthCount = list.length);
            break;
          case 'thisweek':
            _maybeUpdateCount(_weekCount, () => _weekCount = list.length);
            break;
          case 'new':
            _maybeUpdateCount(_logCount, () => _logCount = list.length);
            break;
          case 'pending':
            _maybeUpdateCount(_pendingCount, () => _pendingCount = list.length);
            break;
          default:
            if (opt == todayStr) {
              _maybeUpdateCount(_todayCount, () => _todayCount = list.length);
            }
        }
      });

      switch (widget.initialView) {
        case 'pending':
          _selectedNavIndex = 4;
          _loadPendingBookings(bookingProvider);
          break;
        case 'today':
          _selectedNavIndex = 1;
          _loadTodayBookings(bookingProvider);
          break;
        case 'log':
          _selectedNavIndex = 3;
          _loadLogBookings(bookingProvider);
          break;
        case 'week':
          _selectedNavIndex = 2;
          _loadWeekBookings(bookingProvider);
          break;
        default:
          _selectedNavIndex = 0;
          _loadMonthBookings(bookingProvider);
      }
    });
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  /// Booking card
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                  ),
                ),
              ),
            );
            
            // Navigate after showing loading dialog
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop(); // Close loading dialog
              safePush(context, SummaryPage(booking: booking));
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
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
                    if (booking.createdby?.toLowerCase() != 'salon')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.language,
                            color: Colors.white, size: 12),
                      ),
                    if (booking.status.isNotEmpty)
                      Container(
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
                _infoRow(
                    icon: Icons.person,
                    text: booking.customername,
                    color: color,
                    muted: isPastLocal),
                const SizedBox(height: 4),
                _infoRow(
                    icon: Icons.spa,
                    text: booking.servicename,
                    color: color,
                    muted: isPastLocal),
                const SizedBox(height: 4),
                _infoRow(
                    icon: Icons.person_outline,
                    text: 'Staff: ${booking.staffname}' +
                        (booking.note.isNotEmpty ? ' | Note: ${booking.note}' : ''),
                    color: color,
                    muted: isPastLocal),
                const SizedBox(height: 4),
                _infoRow(
                    icon: Icons.schedule,
                    text: 'Created on: ${_formatSchedule(booking.created_datetime)}',
                    color: color,
                    muted: isPastLocal,
                    textStyle: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    required Color color,
    bool muted = false,
    TextStyle? textStyle,
  }) {
    return Row(children: [
      Icon(icon, color: muted ? Colors.grey[500] : color.withOpacity(0.7), size: 16),
      const SizedBox(width: 4),
      Expanded(
        child: Text(text,
            style: textStyle ??
                TextStyle(
                    color: muted ? Colors.grey[600] : Colors.black54,
                    fontSize: 14)),
      ),
    ]);
  }

  String _formatSchedule(DateTime dateTime) =>
      DateFormat('HH:mm, dd-MM-yyyy').format(dateTime);

  Color _statusColor(String status, Color defaultColor) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait')) return Colors.orange.shade700;
    if (s.contains('confirm') || s.contains('booked') || s.contains('confirmed')) return Colors.green.shade600;
    if (s.contains('cancel') || s.contains('void')) return Colors.red.shade600;
    if (s.contains('done') || s.contains('completed')) return Colors.blueGrey.shade600;
    return defaultColor;
  }

  String _formatDate(DateTime dateTime) =>
      DateFormat('EEEE, d MMMM yyyy').format(dateTime);

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

  static Map<DateTime, List<Booking>> _groupBookingsByDate(List<Booking> bookings) {
    final Map<DateTime, List<Booking>> grouped = {};
    for (final b in bookings) {
      final date = DateTime.parse(b.bookingdate);
      final normalized = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(normalized, () => []).add(b);
    }
    return grouped;
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
        border: Border(left: BorderSide(color: color, width: 4.0)),
      ),
      child: Row(children: [
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
      ]),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    switch (index) {
      case 0:
        _showDatePickerForFind(bookingProvider);
        break;
      case 1:
        _loadTodayBookings(bookingProvider);
        break;
      case 2:
        _loadWeekBookings(bookingProvider);
        break;
      case 3:
        _loadLogBookings(bookingProvider);
        break;
      case 4:
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

    if (pickedDate == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
    setState(() => _isLogView = false);
    bookingProvider.setCurrentViewOption(formattedDate);
    bookingProvider.loadBookingsWithDate(formattedDate);
  }

  void _loadTodayBookings(BookingProvider bookingProvider) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() => _isLogView = false);
    bookingProvider.setCurrentViewOption(today);
    bookingProvider.loadBookingsWithDate(today);
  }

  void _loadWeekBookings(BookingProvider bookingProvider) {
    setState(() => _isLogView = false);
    bookingProvider.setCurrentViewOption('thisweek');
    bookingProvider.loadBookingsWithOption('thisweek');
  }

  void _loadMonthBookings(BookingProvider bookingProvider) {
    setState(() => _isLogView = false);
    bookingProvider.setCurrentViewOption('thismonth');
    bookingProvider.loadBookingsWithOption('thismonth');
  }

  void _loadLogBookings(BookingProvider bookingProvider) {
    setState(() => _isLogView = true);
    bookingProvider.setCurrentViewOption('new');
    bookingProvider.loadBookingsWithOption('new');
  }

  void _loadPendingBookings(BookingProvider bookingProvider) {
    setState(() => _isLogView = false);
    bookingProvider.setCurrentViewOption('pending');
    bookingProvider.loadBookingsWithOption('pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        actions: [
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => _loadMonthBookings(bookingProvider),
              );
            },
          )
        ],
      ),
      drawer: const AppDrawerBooking(),
      body: Consumer<BookingProvider>(builder: (context, bookingProvider, child) {
        return StreamBuilder<List<Booking>>(
          stream: bookingProvider.bookingStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return const Center(child: Text('No bookings available.'));
            }

            if (_isLogView) {
              return Container(
                color: Colors.grey[50],
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => _buildBookingCard(bookings[index], _primaryColor),
                ),
              );
            }

            final grouped = _groupBookingsByDate(bookings);
            final dates = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

            final List<Widget> items = [];
            for (final d in dates) {
              items.add(_buildDateHeader(d, _primaryColor));
              for (final b in grouped[d]!) {
                items.add(_buildBookingCard(b, _primaryColor));
              }
            }

            return Container(
              color: Colors.grey[50],
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: items.length,
                itemBuilder: (context, index) => items[index],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => safePush(context, const StaffPage()),
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: 'Today ($_todayCount)'),
          BottomNavigationBarItem(icon: const Icon(Icons.view_week), label: 'Week ($_weekCount)'),
          BottomNavigationBarItem(icon: const Icon(Icons.assignment), label: 'Log ($_logCount)'),
          BottomNavigationBarItem(icon: const Icon(Icons.hourglass_bottom), label: 'Pending ($_pendingCount)'),
        ],
        currentIndex: _selectedNavIndex,
        onTap: _handleBottomNavTap,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
