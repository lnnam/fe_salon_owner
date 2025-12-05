# Booking Data Flow: From Home to Summary Page

## Overview
This document explains how booking data flows from the `BookingHomeScreen` (home.dart) to the `SummaryPage` (summary.dart).

---

## 1. **Data Source in Home Page**

### Location: `lib/ui/booking/home.dart`

The booking data comes from the **BookingProvider stream**:

```dart
return StreamBuilder<List<Booking>>(
  stream: bookingProvider.bookingStream,  // ← Data source
  builder: (context, snapshot) {
    // snapshot.data contains List<Booking>
```

Each booking in the list is a `Booking` model with all booking details.

---

## 2. **Booking Card Creation**

### Location: `lib/ui/booking/home.dart` - `_buildBookingCard()` method

When a booking card is built, it receives the `Booking` object:

```dart
Widget _buildBookingCard(Booking booking, Color color) {
  // booking parameter contains all booking data
  
  return InkWell(
    onTap: () {
      // When user taps the booking card...
    },
  );
}
```

The booking card is displayed in a list:
```dart
...bookings
    .map((booking) => _buildBookingCard(booking, color))
    .toList(),
```

---

## 3. **Navigation to Summary Page**

### Location: `lib/ui/booking/home.dart` - Line 181

When a user taps a booking card, the navigation happens:

```dart
InkWell(
  onTap: () {
    // Step 1: Log the booking data
    print('[BookingHomeScreen] Booking Tapped - Navigating to Summary');
    print('  - Booking Key: ${booking.pkey}');
    print('  - Customer: ${booking.customername}');
    // ... more logs ...
    
    // Step 2: Pass booking to SummaryPage as a widget parameter
    safePush(context, SummaryPage(booking: booking));
    //                                    ^^^^^^^^^^^^^^
    //                           Named parameter: booking
  },
)
```

---

## 4. **Widget Parameter in Summary Page**

### Location: `lib/ui/booking/summary.dart` - Lines 17-24

The SummaryPage widget constructor accepts the booking:

```dart
class SummaryPage extends StatefulWidget {
  final Booking? booking;  // ← Optional booking parameter
  
  const SummaryPage({super.key, this.booking});
  //                                  ^^^^^^
  //                      Receives booking data here
  
  @override
  _SummaryPageState createState() => _SummaryPageState();
}
```

---

## 5. **Data Access in State Class**

### Location: `lib/ui/booking/summary.dart` - `_SummaryPageState`

The state class can access the booking data via `widget.booking`:

```dart
class _SummaryPageState extends State<SummaryPage> {
  
  @override
  void initState() {
    super.initState();
    
    if (widget.booking != null) {
      // ✅ Booking data is available here!
      final booking = widget.booking!;
      
      // Extract data from booking object
      bookingkey = booking.pkey;
      customerName = booking.customername;
      customerPhone = booking.customerphone;
      staffName = booking.staffname;
      serviceName = booking.servicename;
      status = booking.status;
      // ... and so on
    }
  }
}
```

---

## 6. **Complete Data Flow Diagram**

```
HOME PAGE (home.dart)
    ↓
    └─ Stream: bookingProvider.bookingStream
         ↓
    └─ List<Booking> received in StreamBuilder
         ↓
    └─ Each Booking → _buildBookingCard(booking)
         ↓
    └─ User Taps Booking Card
         ↓
    └─ safePush(context, SummaryPage(booking: booking))
         ↓
SUMMARY PAGE (summary.dart)
    ↓
    └─ Constructor: SummaryPage({this.booking})
         ↓
    └─ State: _SummaryPageState
         ↓
    └─ initState() → widget.booking accessed
         ↓
    └─ Data extracted and stored in local variables
         ↓
    └─ UI built with booking data
```

---

## 7. **Booking Model Fields Available**

When the booking is passed to SummaryPage, all these fields are available:

### Basic Info
- `pkey` (int) - Booking key/ID
- `status` (String) - Booking status
- `note` (String) - Notes/comments

### Customer Info
- `customerkey` (String) - Customer ID
- `customername` (String) - Customer name
- `customerphone` (String) - Phone number
- `customeremail` (String) - Email address
- `customertype` (String) - Customer type
- `customerphoto` (String) - Base64 encoded photo

### Staff & Service
- `staffkey` (String) - Staff ID
- `staffname` (String) - Staff name
- `servicekey` (String) - Service ID
- `servicename` (String) - Service name

### Dates & Times
- `bookingdate` (String) - Booking date (yyyy-MM-dd)
- `bookingtime` (DateTime) - Booking time
- `bookingstart` (DateTime) - When booking starts
- `datetimebooking` (DateTime) - DateTime of booking

### Metadata
- `created_datetime` (DateTime) - When booking was created
- `createdby` (String?) - Who created the booking

---

## 8. **Summary Page Display**

Once the data is passed and extracted, the SummaryPage displays:

1. **Customer Information Bar** - Photo, name, phone, email
2. **Booking Details** - Schedule, customer name, staff, service
3. **Status Badge** - Shows current status with color
4. **Action Buttons** - SMS, Call, Email, Confirm, Save, Delete
5. **Activity Log** - Timeline of booking events
6. **Note Section** - Editable notes field

---

## 9. **Key Points**

✅ **Named Parameter**: The booking is passed as a named parameter `booking`

✅ **Type Safety**: `Booking?` is optional - handles both widget parameter and provider data

✅ **Widget Access**: Data accessed via `widget.booking` in the state class

✅ **Null Check**: Always check `if (widget.booking != null)` before accessing

✅ **Fallback**: If no widget booking, uses `bookingProvider.bookingDetails`

✅ **Logging**: Console logs show exact data being passed at each step

---

## 10. **Code Example - Complete Flow**

```dart
// HOME PAGE - Booking Card Tap
InkWell(
  onTap: () {
    safePush(context, SummaryPage(booking: booking));  // ← Pass booking
  },
)

// SUMMARY PAGE - Constructor
const SummaryPage({super.key, this.booking});  // ← Receive booking

// SUMMARY PAGE - State Access
if (widget.booking != null) {
  final booking = widget.booking!;  // ← Access booking
  customerName = booking.customername;  // ← Extract data
}

// SUMMARY PAGE - Display
Text(customerName)  // ← Use data in UI
```

---

## Verification in Console

When you navigate from home to summary, you'll see logs:

```
═════════════════════════════════════════════════════════════
[BookingHomeScreen] Booking Tapped - Navigating to Summary
  - Booking Key: 123
  - Customer: John Doe
  - Service: Hair Cut
  - Staff: Jane Smith
  - Status: Pending
  - Booking Time: 2024-12-05 14:30:00.000
═════════════════════════════════════════════════════════════

═════════════════════════════════════════════════════════════
[SummaryPage] Data Passed to Summary Page - INIT
═════════════════════════════════════════════════════════════

✅ Booking Object Received from Widget Parameter

BOOKING DETAILS:
  └─ Booking Key (pkey): 123
  └─ Customer Name: John Doe
  └─ Customer Phone: 555-1234
  └─ Staff Name: Jane Smith
  └─ Service Name: Hair Cut
  └─ Status: Pending
  ... (more details)
```

---

This is the complete data flow from home page to summary page!
