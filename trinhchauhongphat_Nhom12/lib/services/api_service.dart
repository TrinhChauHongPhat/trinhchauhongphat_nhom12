import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // - Khi chạy trên Android Emulator: Dùng "http://10.0.2.2:7038/api"
  // - Khi cắm cáp USB chạy máy thật: Dùng IP LAN máy tính ("http://192.168.1.21:5000/api")
  static const String baseUrl = 'https://assumed-remarkable-llp-duncan.trycloudflare.com/api';
  static String? jwtToken;

  // 1. Đăng ký tài khoản
  static Future<Map<String, dynamic>> register(String fullName, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fullName": fullName, "email": email, "password": password, "role": role}),
      );

      print("Register Status: ${response.statusCode}");
      print("Register Body: '${response.body}'");

      if (response.body.isEmpty) {
        return {
          "success": false,
          "message": "Server trả về phản hồi trống (Mã lỗi: ${response.statusCode})"
        };
      }

      var data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "success": false,
          "message": data['message'] ?? "Đăng ký thất bại (Mã: ${response.statusCode})"
        };
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối Backend: $e"};
    }
  }

  // 2a. Bước 1 Đăng nhập: Gửi Email + Password nhận OTP về Mail
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login Status: ${response.statusCode}");
      print("Login Body: '${response.body}'");

      if (response.body.isEmpty) {
        return {"success": false, "message": "Server trả về phản hồi trống (Mã lỗi: ${response.statusCode})"};
      }

      var data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        return {"success": false, "message": data['message'] ?? "Đăng nhập thất bại"};
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối Backend: $e"};
    }
  }

  // 2b. Bước 2 Đăng nhập: Xác thực OTP nhận Token & Role
  static Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otpCode": otpCode}),
      );

      print("VerifyOtp Status: ${response.statusCode}");
      print("VerifyOtp Body: '${response.body}'");

      if (response.body.isEmpty) {
        return {"success": false, "message": "Server trả về phản hồi trống"};
      }

      var data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        jwtToken = data['token'];
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Lỗi xác thực OTP: $e"};
    }
  }

  // 4. CRUD Thiết bị con của Phụ huynh
  static Future<List<dynamic>> getMyKids(int parentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/children/my-kids/$parentId'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi getMyKids: $e");
    }
    return [];
  }

  static Future<bool> createChild(int parentId, String childName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/children/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"parentId": parentId, "childName": childName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleLock(int deviceId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/children/toggle-lock/$deviceId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteChild(int deviceId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/children/$deviceId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Gửi cảnh báo khẩn cấp SOS từ thiết bị trẻ
  static Future<bool> sendEmergencySos(int deviceId, String childName, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/children/sos'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "deviceId": deviceId,
          "childName": childName,
          "message": message,
          "timestamp": DateTime.now().toIso8601String()
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi sendEmergencySos: $e");
      return false;
    }
  }

  // 5b. Cập nhật & Lấy tọa độ GPS
  static Future<bool> updateLocation(int deviceId, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracking/update-location'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"deviceId": deviceId, "latitude": lat, "longitude": lng}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getLocation(int deviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tracking/location/$deviceId'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi getLocation: $e");
    }
    return null;
  }

  // Thống kê Admin
  static Future<Map<String, dynamic>?> getAdminSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/dashboard-summary'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi Admin Summary: $e");
    }
    return null;
  }

  // Thống kê Staff
  static Future<Map<String, dynamic>?> getStaffDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/staff/support-dashboard'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi Staff Dashboard: $e");
    }
    return null;
  }

  // 6. Đăng xuất tài khoản
  static void logout() {
    jwtToken = null;
  }
}