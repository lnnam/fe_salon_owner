# Booking Setting API Documentation (MySQL Version)

## Database Table Structure
```sql
CREATE TABLE `tblsetting` (
  `pkey` int(11) NOT NULL AUTO_INCREMENT,
  `onoff` varchar(5) DEFAULT NULL,
  `autoconfirm` varchar(5) DEFAULT NULL,
  `maxbooking` tinyint(2) DEFAULT NULL,
  `num_staff_for_autobooking` tinyint(2) DEFAULT NULL,
  `sundayoff` varchar(5) DEFAULT NULL,
  `listoffday` varchar(1000) DEFAULT NULL,
  `timestaff` int(11) DEFAULT NULL,
  `listhouroff` varchar(1000) DEFAULT NULL,
  `email_title` varchar(500) DEFAULT NULL,
  `salon_email` varchar(500) DEFAULT NULL,
  `salon_name` text,
  `salon_phone` varchar(20) DEFAULT NULL,
  `link_review_google` varchar(5000) DEFAULT NULL,
  `link_review_facebook` varchar(5000) DEFAULT NULL,
  `link_review_salon` varchar(5000) DEFAULT NULL,
  `link_booking` varchar(5000) DEFAULT NULL,
  `salon_infor` varchar(500) DEFAULT NULL,
  `birthday_sms` varchar(5000) DEFAULT NULL,
  `booking_message` varchar(5000) DEFAULT NULL,
  `sms` varchar(1000) DEFAULT NULL,
  `email` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
```

---

## Frontend (Dart/Flutter) - Data to Submit

```dart
final settingsData = {
  'numStaffAutoBooking': 4,              // Maps to: num_staff_for_autobooking
  'onOff': true,                         // Maps to: onoff (1 or 0)
  'openSunday': false,                   // Maps to: sundayoff (1 or 0)
  'aiConfirm': false,                    // Maps to: autoconfirm (1 or 0)
  'daysOff': '2025-08-23,2025-08-25,2025-08-26',  // Maps to: listoffday
  'hoursOff': '18,19,20,',               // Maps to: listhouroff
};
```

---

## Backend (Node.js) - Server Code

### 1. Route Definition
```javascript
// routes/booking.js or routes/setting.js
router.post('/booking/owner/setting/save', verifyToken, SaveBookingSetting);
router.get('/booking/owner/setting/get', verifyToken, GetBookingSetting);
```

### 2. Controller Function
```javascript
// controllers/settingController.js

const mysql = require('mysql2/promise');
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'salon_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

/**
 * Save Booking Settings
 * POST /booking/owner/setting/save
 */
const SaveBookingSetting = async (req, res) => {
  let connection;
  try {
    const { 
      numStaffAutoBooking, 
      onOff, 
      openSunday, 
      aiConfirm, 
      daysOff, 
      hoursOff 
    } = req.body;

    // Validate input
    if (typeof numStaffAutoBooking !== 'number' || numStaffAutoBooking < 1) {
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid number of staff' 
      });
    }

    // Convert boolean to 1/0 for MySQL
    const onoffValue = onOff ? 1 : 0;
    const sundayoffValue = openSunday ? 1 : 0;
    const autoconfirmValue = aiConfirm ? 1 : 0;

    connection = await pool.getConnection();

    // Check if setting exists
    const [existingSettings] = await connection.query(
      'SELECT pkey FROM tblsetting LIMIT 1'
    );

    let result;
    if (existingSettings.length > 0) {
      // UPDATE existing record (usually only one record in settings table)
      result = await connection.query(
        `UPDATE tblsetting 
         SET 
           num_staff_for_autobooking = ?,
           onoff = ?,
           sundayoff = ?,
           autoconfirm = ?,
           listoffday = ?,
           listhouroff = ?
         WHERE pkey = ?`,
        [
          numStaffAutoBooking,
          onoffValue,
          sundayoffValue,
          autoconfirmValue,
          daysOff,
          hoursOff,
          existingSettings[0].pkey
        ]
      );
      
      console.log('[SettingController] Settings updated:', result);
      
      return res.status(200).json({
        success: true,
        message: 'Settings updated successfully',
        data: {
          pkey: existingSettings[0].pkey,
          num_staff_for_autobooking: numStaffAutoBooking,
          onoff: onoffValue,
          sundayoff: sundayoffValue,
          autoconfirm: autoconfirmValue,
          listoffday: daysOff,
          listhouroff: hoursOff,
        },
      });
    } else {
      // INSERT new record
      result = await connection.query(
        `INSERT INTO tblsetting 
         (num_staff_for_autobooking, onoff, sundayoff, autoconfirm, listoffday, listhouroff)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          numStaffAutoBooking,
          onoffValue,
          sundayoffValue,
          autoconfirmValue,
          daysOff,
          hoursOff
        ]
      );

      console.log('[SettingController] Settings created:', result);

      return res.status(201).json({
        success: true,
        message: 'Settings created successfully',
        data: {
          pkey: result[0].insertId,
          num_staff_for_autobooking: numStaffAutoBooking,
          onoff: onoffValue,
          sundayoff: sundayoffValue,
          autoconfirm: autoconfirmValue,
          listoffday: daysOff,
          listhouroff: hoursOff,
        },
      });
    }
  } catch (error) {
    console.error('[SettingController] Error saving settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to save settings',
      error: error.message,
    });
  } finally {
    if (connection) {
      await connection.release();
    }
  }
};

/**
 * Get Booking Settings
 * GET /booking/owner/setting/get
 */
const GetBookingSetting = async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const [settings] = await connection.query(
      'SELECT * FROM tblsetting LIMIT 1'
    );

    if (settings.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Settings not found',
      });
    }

    const setting = settings[0];

    // Convert MySQL values to readable format
    return res.status(200).json({
      success: true,
      data: {
        pkey: setting.pkey,
        numStaffAutoBooking: setting.num_staff_for_autobooking,
        onOff: setting.onoff === 1 || setting.onoff === '1',
        openSunday: setting.sundayoff === 1 || setting.sundayoff === '1',
        aiConfirm: setting.autoconfirm === 1 || setting.autoconfirm === '1',
        daysOff: setting.listoffday || '',
        hoursOff: setting.listhouroff || '',
        salonName: setting.salon_name || '',
        salonPhone: setting.salon_phone || '',
        salonEmail: setting.salon_email || '',
      },
    });
  } catch (error) {
    console.error('[SettingController] Error fetching settings:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch settings',
      error: error.message,
    });
  } finally {
    if (connection) {
      await connection.release();
    }
  }
};

module.exports = { SaveBookingSetting, GetBookingSetting };
```

### 3. API Manager Update (Dart/Flutter)
```dart
// lib/api/api_manager.dart

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

Future<Map<String, dynamic>?> GetBookingSetting() async {
  try {
    final response = await getData('booking/owner/setting/get');
    if (response['success'] == true) {
      return response['data'];
    }
    return null;
  } catch (e) {
    print('[API] Error fetching booking setting: $e');
    return null;
  }
}
```

### 4. Update Flutter to Use Real API
```dart
// lib/ui/booking/setting.dart - Updated _saveSettings method

void _saveSettings() async {
  try {
    // Collect all settings data
    final numStaff = int.parse(_numStaffController.text);
    
    final daysOffString = _selectedDaysOff
        .map((date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}')
        .join(',');
    
    final hoursOff = _hoursOffController.text;

    final settingsData = {
      'numStaffAutoBooking': numStaff,
      'onOff': _autoBooking,
      'openSunday': _openSunday,
      'aiConfirm': _aiConfirm,
      'daysOff': daysOffString,
      'hoursOff': hoursOff,
    };

    print('[SettingPage] Saving settings: $settingsData');

    // Call API
    final result = await apiManager.SaveBookingSetting(settingsData);
    if (result) {
      showAlertDialog(context, 'Success', 'Settings saved successfully');
    } else {
      showAlertDialog(context, 'Error', 'Failed to save settings');
    }
  } catch (e) {
    showAlertDialog(context, 'Error', 'Failed to save settings: $e');
  }
}

// Load settings when page opens (optional)
Future<void> _loadSettings() async {
  try {
    final settings = await apiManager.GetBookingSetting();
    if (settings != null) {
      setState(() {
        _numStaffController.text = settings['numStaffAutoBooking']?.toString() ?? '4';
        _autoBooking = settings['onOff'] ?? true;
        _openSunday = settings['openSunday'] ?? false;
        _aiConfirm = settings['aiConfirm'] ?? false;
        _hoursOffController.text = settings['hoursOff'] ?? '';
        
        // Parse daysOff string to list
        if (settings['daysOff'] != null && settings['daysOff'].isNotEmpty) {
          final dateFormat = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
          final matches = dateFormat.allMatches(settings['daysOff']);
          for (var match in matches) {
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            _selectedDaysOff.add(DateTime(year, month, day));
          }
        }
      });
    }
  } catch (e) {
    print('[SettingPage] Error loading settings: $e');
  }
}
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

### Response (Success - Create)
```json
{
  "success": true,
  "message": "Settings created successfully",
  "data": {
    "pkey": 1,
    "num_staff_for_autobooking": 4,
    "onoff": 1,
    "sundayoff": 0,
    "autoconfirm": 0,
    "listoffday": "2025-08-23,2025-08-25,2025-08-26",
    "listhouroff": "18,19,20,"
  }
}
```

### Response (Success - Update)
```json
{
  "success": true,
  "message": "Settings updated successfully",
  "data": {
    "pkey": 1,
    "num_staff_for_autobooking": 4,
    "onoff": 1,
    "sundayoff": 0,
    "autoconfirm": 0,
    "listoffday": "2025-08-23,2025-08-25,2025-08-26",
    "listhouroff": "18,19,20,"
  }
}
```

### Response (Get Settings)
```json
{
  "success": true,
  "data": {
    "pkey": 1,
    "numStaffAutoBooking": 4,
    "onOff": true,
    "openSunday": false,
    "aiConfirm": false,
    "daysOff": "2025-08-23,2025-08-25,2025-08-26",
    "hoursOff": "18,19,20,",
    "salonName": "My Salon",
    "salonPhone": "123-456-7890",
    "salonEmail": "salon@example.com"
  }
}
```

---

## Field Mapping

| Flutter | MySQL Column | Type | Description |
|---------|--------------|------|-------------|
| numStaffAutoBooking | num_staff_for_autobooking | tinyint(2) | Number of staff for auto booking |
| onOff | onoff | varchar(5) | ON/OFF toggle (1 or 0) |
| openSunday | sundayoff | varchar(5) | Open on Sunday (1 or 0) |
| aiConfirm | autoconfirm | varchar(5) | AI Confirm (1 or 0) |
| daysOff | listoffday | varchar(1000) | Comma-separated dates |
| hoursOff | listhouroff | varchar(1000) | Comma-separated hours |

---

## Implementation Steps

1. ✅ Create MySQL table `tblsetting`
2. Create Node.js controller `settingController.js`
3. Add routes for POST (save) and GET (retrieve)
4. Add validation middleware
5. Update Dart API manager with `SaveBookingSetting()` and `GetBookingSetting()` methods
6. Update the `_saveSettings()` method in Flutter to call real API
7. Optionally add `_loadSettings()` to load existing settings on page load
8. Test with Postman or Insomnia
9. Deploy to production
