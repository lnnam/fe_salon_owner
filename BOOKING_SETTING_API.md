# Booking Setting API Documentation

## Frontend (Dart/Flutter) - Client Code

The setting page collects the following data:

```dart
final settingsData = {
  'numStaffAutoBooking': 4,              // Number of staff for auto booking
  'onOff': true,                         // ON/OFF toggle for auto booking
  'openSunday': false,                   // Open on Sunday toggle
  'aiConfirm': false,                    // AI Confirm toggle
  'daysOff': '2025-08-23,2025-08-25,2025-08-26',  // Comma-separated dates
  'hoursOff': '18,19,20,',               // Comma-separated hours
};
```

### Frontend API Call (to implement in Flutter)
```dart
// In lib/api/api_manager.dart, add:
Future<bool> SaveBookingSetting(Map<String, dynamic> data) async {
  try {
    final response = await postData(
      'booking/owner/setting/save',
      data,
    );
    return response['success'] ?? false;
  } catch (e) {
    print('[API] Error saving booking setting: $e');
    return false;
  }
}
```

---

## Backend (Node.js) - Server Code

### 1. Route Definition
```javascript
// routes/booking.js or routes/admin.js
router.post('/booking/owner/setting/save', verifyToken, SaveBookingSetting);
```

### 2. Controller Function
```javascript
// controllers/bookingController.js

const SaveBookingSetting = async (req, res) => {
  try {
    const { 
      numStaffAutoBooking, 
      onOff, 
      openSunday, 
      aiConfirm, 
      daysOff, 
      hoursOff 
    } = req.body;

    const ownerId = req.user.id; // From JWT token

    // Validate input
    if (!numStaffAutoBooking || typeof numStaffAutoBooking !== 'number') {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid number of staff' 
      });
    }

    // Find or create settings record for this owner
    let settings = await BookingSetting.findOne({ owner_id: ownerId });

    if (!settings) {
      settings = new BookingSetting({
        owner_id: ownerId,
      });
    }

    // Update settings
    settings.num_staff_auto_booking = numStaffAutoBooking;
    settings.on_off = onOff;
    settings.open_sunday = openSunday;
    settings.ai_confirm = aiConfirm;
    settings.days_off = daysOff; // Store as string or parse to array
    settings.hours_off = hoursOff; // Store as string or parse to array
    settings.updated_at = new Date();

    // Save to database
    const savedSettings = await settings.save();

    return res.status(200).json({
      success: true,
      message: 'Settings saved successfully',
      data: savedSettings,
    });
  } catch (error) {
    console.error('[BookingSetting] Error saving settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to save settings',
      error: error.message,
    });
  }
};

module.exports = { SaveBookingSetting };
```

### 3. Database Model (Mongoose Schema)
```javascript
// models/BookingSetting.js

const BookingSettingSchema = new Schema({
  owner_id: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  num_staff_auto_booking: {
    type: Number,
    default: 4,
  },
  on_off: {
    type: Boolean,
    default: true,
  },
  open_sunday: {
    type: Boolean,
    default: false,
  },
  ai_confirm: {
    type: Boolean,
    default: false,
  },
  days_off: {
    type: String, // Format: "YYYY-MM-DD,YYYY-MM-DD,..."
    default: '',
  },
  hours_off: {
    type: String, // Format: "18,19,20,"
    default: '',
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('BookingSetting', BookingSettingSchema);
```

### 4. Helper Function to Parse Days Off (Optional)
```javascript
// utils/dateHelper.js

const parseDaysOff = (daysOffString) => {
  if (!daysOffString) return [];
  return daysOffString.split(',').filter(date => date.trim() !== '');
};

const parseHoursOff = (hoursOffString) => {
  if (!hoursOffString) return [];
  return hoursOffString.split(',')
    .map(h => parseInt(h.trim()))
    .filter(h => !isNaN(h));
};

module.exports = { parseDaysOff, parseHoursOff };
```

### 5. Validation Middleware (Optional but Recommended)
```javascript
// middleware/validateBookingSetting.js

const validateBookingSetting = (req, res, next) => {
  const { numStaffAutoBooking, onOff, openSunday, aiConfirm, daysOff, hoursOff } = req.body;

  // Validate numStaffAutoBooking
  if (typeof numStaffAutoBooking !== 'number' || numStaffAutoBooking < 1) {
    return res.status(400).json({
      success: false,
      message: 'numStaffAutoBooking must be a positive number',
    });
  }

  // Validate boolean fields
  if (typeof onOff !== 'boolean' || typeof openSunday !== 'boolean' || typeof aiConfirm !== 'boolean') {
    return res.status(400).json({
      success: false,
      message: 'Boolean fields must be true or false',
    });
  }

  // Validate daysOff format (optional - only if provided)
  if (daysOff && !/^\d{4}-\d{2}-\d{2}(,\d{4}-\d{2}-\d{2})*,?$/.test(daysOff)) {
    return res.status(400).json({
      success: false,
      message: 'daysOff must be in format: YYYY-MM-DD,YYYY-MM-DD,...',
    });
  }

  next();
};

module.exports = validateBookingSetting;
```

### 6. Usage in Route with Validation
```javascript
// routes/booking.js

const validateBookingSetting = require('../middleware/validateBookingSetting');

router.post(
  '/booking/owner/setting/save',
  verifyToken,
  validateBookingSetting,
  SaveBookingSetting
);
```

---

## Data Format Examples

### Request Body (JSON)
```json
{
  "numStaffAutoBooking": 4,
  "onOff": true,
  "openSunday": false,
  "aiConfirm": false,
  "daysOff": "2025-08-23,2025-08-25,2025-08-26",
  "hoursOff": "18,19,20,"
}
```

### Response (Success)
```json
{
  "success": true,
  "message": "Settings saved successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "owner_id": "507f1f77bcf86cd799439012",
    "num_staff_auto_booking": 4,
    "on_off": true,
    "open_sunday": false,
    "ai_confirm": false,
    "days_off": "2025-08-23,2025-08-25,2025-08-26",
    "hours_off": "18,19,20,",
    "created_at": "2025-12-07T10:00:00Z",
    "updated_at": "2025-12-07T10:30:00Z"
  }
}
```

### Response (Error)
```json
{
  "success": false,
  "message": "Invalid number of staff"
}
```

---

## Next Steps

1. Create the MongoDB model for `BookingSetting`
2. Implement the controller function `SaveBookingSetting` in Node.js
3. Add the route to handle POST requests
4. Uncomment the API call in the Dart code once backend is ready
5. Test the integration with Postman or similar tool
