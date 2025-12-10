import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/provider/setting.provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salonapp/constants.dart';

import 'home.dart';
import 'calendar.dart'; // ⬅️ Replace with actual path
import 'staff.dart'; // ⬅️ Replace with actual path
import 'customer.dart'; // ⬅️ Replace with actual path
import 'service.dart'; // ⬅️ Replace with actual path
import 'booking_actions.dart';

class SummaryPage extends StatefulWidget {
  final Booking? booking;

  const SummaryPage({super.key, this.booking});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool isLoading = false;
  String note = '';

  late String customerKey;
  late String serviceKey;
  late String staffKey;
  late String bookingDate;
  late String bookingTime;
  late String customerName;
  late String customerPhone;
  late String customerEmail;
  late String staffName;
  late String serviceName;
  late String status;
  late int bookingkey;
  late TextEditingController noteController;
  ImageProvider? customerImage;

  @override
  void dispose() {
    Provider.of<BookingProvider>(context, listen: false)
        .setNote(noteController.text);
    noteController.dispose();
    print('[SummaryPage] Closed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Set edit mode immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<BookingProvider>(context, listen: false).setEditMode(true);
      }
    });

    if (widget.booking != null) {
      final booking = widget.booking!;
      bookingkey = booking.pkey;
      customerKey = booking.customerkey;
      serviceKey = booking.servicekey;
      staffKey = booking.staffkey;
      bookingDate = booking.bookingdate;
      bookingTime = DateFormat('HH:mm, dd/MM/yyyy').format(booking.bookingtime);
      customerName = booking.customername;
      customerPhone =
          booking.customerphone.isNotEmpty ? booking.customerphone : 'N/A';
      customerEmail =
          booking.customeremail.isNotEmpty ? booking.customeremail : 'N/A';

      staffName = booking.staffname;
      serviceName = booking.servicename;
      status = booking.status;
      note = booking.note;

      // Decode base64 image asynchronously without blocking UI
      if (booking.customerphoto.isNotEmpty) {
        decodeBase64Image(booking.customerphoto).then((img) {
          if (!mounted) return;
          setState(() {
            customerImage = img;
          });
        });
      }
    } else {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final bookingDetails = bookingProvider.bookingDetails;
      bookingkey = bookingDetails['bookingkey'] ?? 0;
      customerKey = bookingDetails['customerkey'] ?? '';
      serviceKey = bookingDetails['servicekey'] ?? '';
      staffKey = bookingDetails['staffkey'] ?? '';
      bookingDate = bookingDetails['date'] ?? '';
      bookingTime = bookingDetails['formattedschedule'] ?? '';
      customerName = bookingDetails['customername'] ?? 'Unknown';
      customerPhone = bookingDetails['customerphone'] ?? 'N/A';
      customerEmail = bookingDetails['customeremail'] ?? 'N/A';
      staffName = bookingDetails['staffname'] ?? 'Unknown';
      serviceName = bookingDetails['servicename'] ?? 'Unknown';
      note = bookingDetails['note'] ?? '';
      status =
          bookingDetails['status'] ?? bookingDetails['bookingstatus'] ?? '';
    }

    noteController = TextEditingController(text: note);

    // Set booking details after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.setBookingKey(bookingkey);
      if (widget.booking != null) {
        bookingProvider.setBookingFromModel(widget.booking!);
      }
    });
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait')) {
      return Colors.orange.shade700;
    }
    if (s.contains('confirm') ||
        s.contains('booked') ||
        s.contains('confirmed')) {
      return Colors.green.shade600;
    }
    if (s.contains('cancel') || s.contains('void')) return Colors.red.shade600;
    if (s.contains('done') || s.contains('completed')) {
      return Colors.blueGrey.shade600;
    }
    return Colors.grey.shade600;
  }

  String _friendlyStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait')) return 'Pending';
    if (s.contains('confirm') ||
        s.contains('book') ||
        s.contains('booked') ||
        s.contains('confirmed')) {
      return 'Confirmed';
    }
    if (s.contains('cancel') || s.contains('void')) return 'Cancelled';
    if (s.contains('done') || s.contains('completed')) return 'Completed';
    return status;
  }

  Future<void> _confirmBooking() async {
    setState(() => isLoading = true);
    try {
      final success = await apiManager.confirmBookingOwner(bookingkey);
      if (!mounted) return;
      setState(() => isLoading = false);
      if (success) {
        // Update local status, the passed booking model (if any), and provider
        setState(() {
          status = 'Confirmed';
        });
        safeShowDialog(
          context,
          (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    'Booking Confirmed',
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
                    'Your booking has been confirmed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  // Info message removed per request
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate back to home list after confirmation
                    if (mounted) {
                      // Reload pending list when returning to home
                      final bookingProvider =
                          Provider.of<BookingProvider>(context, listen: false);
                      bookingProvider.loadBookingsWithOption('pending');
                      safePushAndRemoveUntil(
                        context,
                        const BookingHomeScreen(initialView: 'pending'),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        safeShowDialog(
          context,
          (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confirmation Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to confirm booking. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Check your connection and try again.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      safeShowDialog(
        context,
        (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
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

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final isPending = s.contains('pending') || s.contains('wait');
    final isConfirmed = s.contains('confirm') ||
        s.contains('confirmed') ||
        s.contains('booked') ||
        s.contains('book');

    // Debug: Check phone availability
    print(
        '[SummaryPage] Build - customerPhone: $customerPhone, empty: ${customerPhone.isEmpty}, isNA: ${customerPhone == "N/A"}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Booking'),
        backgroundColor: const Color(COLOR_PRIMARY),
        actions: [
          if (status.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  // Prefer local status (updated after confirm), fallback to
                  // the model's friendly label when local status is empty.
                  status.isNotEmpty
                      ? _friendlyStatus(status)
                      : (widget.booking != null
                          ? widget.booking!.displayStatus
                          : status),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          // SMS Button
          if (customerPhone.isNotEmpty && customerPhone != 'N/A')
            IconButton(
              icon: const Icon(Icons.sms, color: Colors.white),
              tooltip: 'SMS',
              splashRadius: 24,
              onPressed: () {
                print(
                    '[SummaryPage] SMS button pressed, phone: $customerPhone');
                _openSMS(customerPhone);
              },
            )
          else
            const Opacity(
              opacity: 0.5,
              child: IconButton(
                icon: Icon(Icons.sms, color: Colors.white),
                tooltip: 'SMS not available',
                splashRadius: 24,
                onPressed: null,
              ),
            ),
          // Call Button
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            tooltip: 'Call',
            onPressed: customerPhone.isNotEmpty && customerPhone != 'N/A'
                ? () => _makeCall(customerPhone)
                : null,
          ),
          // Email Button
          IconButton(
            icon: const Icon(Icons.email, color: Colors.white),
            tooltip: 'Email',
            onPressed: customerEmail.isNotEmpty && customerEmail != 'N/A'
                ? () => _sendEmail(customerEmail)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white),
            tooltip: 'Cancel',
            onPressed: isLoading
                ? null
                : () {
                    safePushAndRemoveUntil(
                      context,
                      const BookingHomeScreen(),
                      (route) => false,
                    );
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Information Sub-Navigation Bar
          Container(
            color: Colors.grey[100],
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    if (customerImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image(
                          image: customerImage!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue[300],
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 24),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (customerPhone.isNotEmpty &&
                              customerPhone != 'N/A')
                            Text(
                              customerPhone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          if (customerEmail.isNotEmpty &&
                              customerEmail != 'N/A')
                            Text(
                              customerEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Confirm button below customer info
                if (status.isNotEmpty && !isConfirmed)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isPending
                            ? ElevatedButton(
                                onPressed:
                                    isLoading ? null : () => _confirmBooking(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(COLOR_PRIMARY),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Confirm',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _statusColor(status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Schedule row
                  _buildInfoRow(
                    context,
                    label: 'Schedule',
                    value:
                        '${_formatDate(bookingDate)} at ${_formatTime(bookingTime)}',
                    icon: Icons.schedule,
                    onTap: () => safePush(context, const BookingCalendarPage()),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: 'Customer Name',
                    value: customerName,
                    icon: Icons.person,
                    onTap: () => safePush(context, const CustomerPage()),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: 'Staff',
                    value: staffName,
                    icon: Icons.people,
                    onTap: () => safePush(context, const StaffPage()),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: 'Service',
                    value: serviceName,
                    icon: Icons.star,
                    onTap: () => safePush(context, const ServicePage()),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Note:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      hintText: 'Enter any notes here...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      note = value;
                      Provider.of<BookingProvider>(context, listen: false)
                          .setNote(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => saveBooking(
                                        context,
                                        bookingkey,
                                        (bool val) => setState(() => isLoading =
                                            val), // <-- Accepts a bool
                                        customerKey,
                                        serviceKey,
                                        staffKey,
                                        bookingDate,
                                        bookingTime,
                                        note,
                                        customerName,
                                        staffName,
                                        serviceName,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(COLOR_PRIMARY),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Save Booking',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  isLoading ? null : () => _sendSMSConfirm(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              icon: const Icon(Icons.sms),
                              label: const Text(
                                'SMS Confirm',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.booking != null)
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final bookingProvider =
                                      Provider.of<BookingProvider>(context,
                                          listen: false);
                                  final currentView =
                                      bookingProvider.currentViewOption;
                                  deleteBookingAction(
                                    context,
                                    isLoading,
                                    (val) => setState(() => isLoading = val),
                                    widget.booking,
                                    currentView: currentView,
                                  );
                                },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required String label,
      required String value,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: const Color(COLOR_PRIMARY)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('d MMMM').format(parsed); // e.g., 10 April
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat('HH:mm').parse(time);
      return DateFormat('HH:mm').format(parsed); // 24h format
    } catch (e) {
      return time;
    }
  }

  Future<void> _openSMS(String phoneNumber) async {
    try {
      print('[SummaryPage] _openSMS called with phone: $phoneNumber');

      // Get SMS message from SettingProvider (reads from SharedPreferences)
      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      print('[SummaryPage] Getting SMS pending message from SharedPreferences');

      // Get settings directly from SharedPreferences
      final smsMessage = await settingProvider.getSmsPending() ?? '';
      final salonName = await settingProvider.getSalonName() ?? '';

      print(
          '[SummaryPage] SMS - smsMessage: $smsMessage, salonName: $salonName');

      // Replace placeholders with actual booking details
      // Extract time from bookingTime (format: "HH:mm, dd/MM/yyyy")
      final timeParts = bookingTime.split(', ');
      final time = timeParts.isNotEmpty ? timeParts[0] : '';
      final date = timeParts.length > 1 ? timeParts[1] : '';

      // Replace HH:MM on DD/MM/YYYY with actual values
      final finalMessage =
          smsMessage.replaceAll('HH:MM on DD/MM/YYYY', '$time on $date');
      print('[SummaryPage] SMS - Phone: $phoneNumber, Message: $finalMessage');

      if (finalMessage.isEmpty) {
        print(
            '[SummaryPage] SMS message is empty - sms_pending not configured');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS message not configured in settings'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final String body = '$finalMessage\n\n$salonName';
      print('[SummaryPage] SMS body: $body');
      print('[SummaryPage] SMS phoneNumber: $phoneNumber');
      // Use proper SMS URI format: sms:phonenumber?body=message
      // Note: Must use Uri.parse instead of Uri constructor to properly encode the body
      final Uri smsUri =
          Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(body)}');

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    } catch (e) {
      print('[SummaryPage] Error in _openSMS: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening SMS: $e')),
      );
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone app')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening phone: $e')),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      // Get email message from SettingProvider (reads from SharedPreferences)
      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      print('[SummaryPage] Getting email message from SharedPreferences');

      // Get settings directly from SharedPreferences
      final emailMessage = await settingProvider.getEmail() ?? '';
      final salonName = await settingProvider.getSalonName() ?? '';

      // Replace placeholders with actual booking details
      // Extract time from bookingTime (format: "HH:mm, dd/MM/yyyy")
      final timeParts = bookingTime.split(', ');
      final time = timeParts.isNotEmpty ? timeParts[0] : '';
      final date = timeParts.length > 1 ? timeParts[1] : '';

      // Replace HH:MM on DD/MM/YYYY with actual values
      final finalMessage =
          emailMessage.replaceAll('HH:MM on DD/MM/YYYY', '$time on $date');
      print('[SummaryPage] Email - Recipient: $email, Message: $finalMessage');

      if (finalMessage.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email message not configured in settings'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final String body = '$finalMessage\n\n$salonName';
      final Uri emailUri =
          Uri.parse('mailto:$email?body=${Uri.encodeComponent(body)}');

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    } catch (e) {
      print('[SummaryPage] Error in _sendEmail: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening email: $e')),
      );
    }
  }

  Future<void> _sendSMSConfirm() async {
    try {
      print('[SummaryPage] _sendSMSConfirm called');

      // Get SMS confirm message from SettingProvider (reads from SharedPreferences)
      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      print('[SummaryPage] Getting SMS confirm message from SharedPreferences');

      // Get settings directly from SharedPreferences
      final smsMessage = await settingProvider.getSmsConfirm() ?? '';
      final salonName = await settingProvider.getSalonName() ?? '';

      print(
          '[SummaryPage] SMS Confirm - smsMessage: $smsMessage, salonName: $salonName');

      // Replace placeholders with actual booking details
      // Extract time from bookingTime (format: "HH:mm, dd/MM/yyyy")
      final timeParts = bookingTime.split(', ');
      final time = timeParts.isNotEmpty ? timeParts[0] : '';
      final date = timeParts.length > 1 ? timeParts[1] : '';

      // Replace HH:MM on DD/MM/YYYY with actual values
      final finalMessage =
          smsMessage.replaceAll('HH:MM on DD/MM/YYYY', '$time on $date');
      print(
          '[SummaryPage] SMS Confirm - Phone: $customerPhone, Message after replacement: $finalMessage');

      if (finalMessage.isEmpty) {
        print(
            '[SummaryPage] SMS confirm message is empty - sms_confirm not configured');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS confirm message not configured in settings'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final String body = '$finalMessage\n\n$salonName';
      print('[SummaryPage] SMS Confirm body: $body');
      print('[SummaryPage] SMS Confirm phoneNumber: $customerPhone');

      // Use proper SMS URI format: sms:phonenumber?body=message
      final Uri smsUri =
          Uri.parse('sms:$customerPhone?body=${Uri.encodeComponent(body)}');

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    } catch (e) {
      print('[SummaryPage] Error in _sendSMSConfirm: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SMS: $e')),
      );
    }
  }
}
