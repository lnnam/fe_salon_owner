class AppConfig {
  //static const api_url = 'https://apiclient.greatyarmouthnails.com';
  static const api_url = 'http://localhost:8080';
  static const api_url_login = '$api_url/api/auth/signin';
  static const api_url_booking_home = '$api_url/api/booking/owner/list';
  static const api_url_booking_staff = '$api_url/api/booking/staff';
  static const api_url_booking_service = '$api_url/api/booking/service';
  static const api_url_booking_customer = '$api_url/api/booking/customer/list';
  static const api_url_booking_customer_add =
      '$api_url/api/booking/customer/add';
  static const api_url_booking_save = '$api_url/api/booking/save';
  static const api_url_booking_del = '$api_url/api/booking/del';
  static const api_url_booking_getavailability =
      '$api_url/api/booking/getavailability';
  static const api_url_booking_confirm = '$api_url/api/booking/owner/confirm';
  static const api_url_booking_setting = '$api_url/api/booking/setting';
  static const api_url_booking_setting_update =
      '$api_url/api/booking/setting/update';

  // CUSTOMER MANAGEMENT
  static const api_url_customer_list =
      '$api_url/api/getdata?storename=GetCustomersList()';

  // STAFF MANAGEMENT
  static const api_url_staff_list = '$api_url/api/staff/list';
  static const api_url_staff_add = '$api_url/api/staff/addstaff';
  static const api_url_staff_get_by_id = '$api_url/api/staff';
  static const api_url_staff_activate = '$api_url/api/staff/activate';
}
