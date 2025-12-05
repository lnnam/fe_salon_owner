import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/provider/setting.provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Resume booking auto-refresh when closing this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resumeAutoRefresh();
    print('[SummaryPage] Closed, auto-refresh resumed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pause booking auto-refresh when opening this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.pauseAutoRefresh();
    print('[SummaryPage] Opened, auto-refresh paused');
    //print('bookingDetails: ${bookingProvider.bookingDetails}');

    // ✅ Set edit mode to true
    //  bookingProvider.setEditMode(true);
    // Schedule provider update after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).setEditMode(true);
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
      // Start async decode of customer image (if any) so UI isn't blocked
      if (booking.customerphoto.isNotEmpty) {
        decodeBase64Image(booking.customerphoto).then((img) {
          if (!mounted) return;
          setState(() {
            customerImage = img;
          });
        });
      }
      bookingProvider.setBookingKey(bookingkey); // ✅ Added here
      bookingProvider.setBookingFromModel(booking);
    } else {
      print('bookingProvider');

      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final bookingDetails = bookingProvider.bookingDetails;
      //   print('Booking : ${bookingDetails}');
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
      noteController = TextEditingController(text: note);
    }

    noteController = TextEditingController(text: note);
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait'))
      return Colors.orange.shade700;
    if (s.contains('confirm') ||
        s.contains('booked') ||
        s.contains('confirmed')) return Colors.green.shade600;
    if (s.contains('cancel') || s.contains('void')) return Colors.red.shade600;
    if (s.contains('done') || s.contains('completed'))
      return Colors.blueGrey.shade600;
    return Colors.grey.shade600;
  }

  String _friendlyStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('wait')) return 'Pending';
    if (s.contains('confirm') ||
        s.contains('book') ||
        s.contains('booked') ||
        s.contains('confirmed')) return 'Confirmed';
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
            title: const Text('Success'),
            content: const Text('Booking confirmed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to home list after confirmation
                  if (mounted) {
                    safePushAndRemoveUntil(
                      context,
                      const BookingHomeScreen(),
                      (route) => false,
                    );
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        safeShowDialog(
          context,
          (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to confirm booking. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Booking'),
        backgroundColor: Colors.blue,
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
          IconButton(
            icon: const Icon(Icons.sms, color: Colors.white),
            tooltip: 'SMS',
            onPressed: customerPhone.isNotEmpty && customerPhone != 'N/A'
                ? () => _openSMS(customerPhone)
                : null,
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
            child: Row(
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
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 24),
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
                      if (customerPhone.isNotEmpty && customerPhone != 'N/A')
                        Text(
                          customerPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (customerEmail.isNotEmpty && customerEmail != 'N/A')
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildInfoRow(
                    context,
                    label: 'Schedule',
                    value:
                        '${_formatDate(bookingDate)} at ${_formatTime(bookingTime)}',
                    icon: Icons.schedule,
                    onTap: () => safePush(context, const BookingCalendarPage()),
                  ),
                  const SizedBox(height: 8),
                  // Under the Schedule section: show confirm button / status
                  // only when booking is present and NOT already confirmed.
                  if (status.isNotEmpty && !isConfirmed)
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        // Show confirm button inline only when status explicitly
                        // indicates pending/wait. We already ensure the whole row
                        // isn't rendered for confirmed bookings via the parent
                        // condition above.
                        isPending
                            ? ElevatedButton(
                                onPressed:
                                    isLoading ? null : () => _confirmBooking(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
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
                                    horizontal: 10, vertical: 6),
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
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => saveBooking(
                                  context,
                                  bookingkey,
                                  (bool val) => setState(() =>
                                      isLoading = val), // <-- Accepts a bool
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
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
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
                      const SizedBox(height: 12),
                      if (widget.booking != null)
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => deleteBookingAction(
                                    context,
                                    isLoading,
                                    (val) => setState(() => isLoading = val),
                                    widget.booking,
                                  ),
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
            Icon(icon, color: Colors.blue),
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
      // Get SMS message from SettingProvider
      final settingProvider = Provider.of<SettingProvider>(context, listen: false);
      var smsMessage = settingProvider.sms ?? '';
      var salonName = settingProvider.salonName ?? '';
      
      // Replace placeholders with actual booking details
      // Extract time from bookingTime (format: "HH:mm, dd/MM/yyyy")
      final timeParts = bookingTime.split(', ');
      final time = timeParts.isNotEmpty ? timeParts[0] : '';
      final date = timeParts.length > 1 ? timeParts[1] : '';
      
      
      // Replace HH:MM on DD/MM/YYYY with actual values
      smsMessage = smsMessage.replaceAll('HH:MM on DD/MM/YYYY', '$time on $date');
      print('[SummaryPage] SMS - Phone: $phoneNumber, Message: $smsMessage');

      if (smsMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS message not configured')),
        );
        return;
      }

      final String body = '$smsMessage\n\n$salonName';
      // Use proper SMS URI format: sms:phonenumber?body=message
      // Note: Must use Uri.parse instead of Uri constructor to properly encode the body
      final Uri smsUri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(body)}');

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    } catch (e) {
      print('[SummaryPage] Error in _openSMS: $e');
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
      // Get email message from SettingProvider
      final settingProvider = Provider.of<SettingProvider>(context, listen: false);
      var emailMessage = settingProvider.email ?? '';
      var salonName = settingProvider.salonName ?? '';
      
      // Replace placeholders with actual booking details
      // Extract time from bookingTime (format: "HH:mm, dd/MM/yyyy")
      final timeParts = bookingTime.split(', ');
      final time = timeParts.isNotEmpty ? timeParts[0] : '';
      final date = timeParts.length > 1 ? timeParts[1] : '';
      
      // Replace HH:MM on DD/MM/YYYY with actual values
      emailMessage = emailMessage.replaceAll('HH:MM on DD/MM/YYYY', '$time on $date');
      print('[SummaryPage] Email - Recipient: $email, Message: $emailMessage');

      if (emailMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email message not configured')),
        );
        return;
      }

      final String body = '$emailMessage\n\n$salonName';
      final Uri emailUri = Uri.parse('mailto:$email?body=${Uri.encodeComponent(body)}');
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    } catch (e) {
      print('[SummaryPage] Error in _sendEmail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening email: $e')),
      );
    }
  }
}