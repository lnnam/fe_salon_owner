import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/config/app_config.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime selectedDate = DateTime.now();
  Map<String, int> slotCounts = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSlotCounts();
  }

  Future<void> _fetchSlotCounts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final String url =
          '${AppConfig.api_url}/api/booking/getavailability/owner?date=$dateStr';
      print('[Schedule] Fetching from URL: $url');
      final response = await apiManager.fetchFromServer(url);
      print('[Schedule] API Response: $response');

      if (response is Map && response['slots'] is List) {
        print('[Schedule] Found ${response['slots'].length} slots');
        final Map<String, int> counts = {};
        for (var slot in response['slots']) {
          print('[Schedule] Processing slot: $slot');
          if (slot is Map &&
              slot['slot_time'] != null &&
              slot['count'] != null) {
            final int count = (slot['count'] is String)
                ? int.parse(slot['count'])
                : (slot['count'] is int)
                    ? slot['count']
                    : slot['count'].toInt();
            // Trim seconds from HH:MM:SS to HH:MM format
            final String slotTime =
                (slot['slot_time'] as String).substring(0, 5);
            counts[slotTime] = count;
            print(
                '[Schedule] Slot: $slotTime -> Count: $count (Type: ${count.runtimeType})');
          }
        }
        print('[Schedule] Final slot counts map: $counts');
        if (mounted) {
          setState(() {
            slotCounts = counts;
          });
          print('[Schedule] State updated. slotCounts: $slotCounts');
        }
      } else {
        print('[Schedule] Invalid response format: ${response.runtimeType}');
        print('[Schedule] Response keys: ${(response as Map?)?.keys}');
      }
    } catch (e) {
      print('[Schedule] Error fetching slot counts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> getTimeSlots() {
    final List<String> slots = [];
    DateTime time =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 0);
    final end = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 19, 0);
    while (time.isBefore(end)) {
      slots.add(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      time = time.add(const Duration(minutes: 15));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = getTimeSlots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  height: 220, // Smaller calendar
                  child: CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                      _fetchSlotCounts();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Available Times',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeSlots[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if ((slotCounts[timeSlots[index]] ?? 0) > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${slotCounts[timeSlots[index]] ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
