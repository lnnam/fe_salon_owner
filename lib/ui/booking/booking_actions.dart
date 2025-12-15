import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'home.dart';

Future<void> saveBooking(
  BuildContext context,
  int bookingKey,
  void Function(bool) setLoading, // <-- Accepts a bool
  String customerKey,
  String serviceKey,
  String staffKey,
  String bookingDate,
  String bookingTime,
  String note,
  String customerName,
  String customerEmail,
  String customerPhone,
  String staffName,
  String serviceName,
) async {
  setLoading(true);

  // debug data omitted in production

  final result = await apiManager.SaveBooking(
    bookingKey,
    customerKey,
    serviceKey,
    staffKey,
    bookingDate,
    bookingTime,
    note,
    customerName,
    customerEmail,
    customerPhone,
    staffName,
    serviceName,
  );

  setLoading(false);

  if (!context.mounted) return;

  if (result != null) {
    safeShowDialog(
      context,
      (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Book now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your booking has been saved successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                safePush(context, const BookingHomeScreen());
              },
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    setLoading(false);
  } else {
    showAlertDialog(
      context,
      'Error : '.tr(),
      'Booking not saved. Contact support!'.tr(),
    );
  }
}

Future<void> deleteBookingAction(
  BuildContext context,
  bool isLoading,
  Function(bool) setLoading,
  dynamic booking, {
  String? currentView,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Booking'),
      content: const Text('Are you sure you want to cancel this booking?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (!context.mounted) return;

  if (confirm == true) {
    setLoading(true);

    bool success = true;
    if (booking != null) {
      success = await apiManager.deleteBooking(booking.pkey);
    }

    setLoading(false);
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
      // Reload the booking list after successful deletion
      if (!context.mounted) return;
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      if (currentView != null) {
        bookingProvider.loadBookingsWithOption(currentView);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to cancel booking. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
