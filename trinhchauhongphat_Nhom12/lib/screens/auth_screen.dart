import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'staff_dashboard.dart';
import 'parent_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _isOtpStep = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String _selectedRole = "Parent";

  final LocalAuthentication _auth = LocalAuthentication();

  // Yêu cầu 5a: Đăng nhập bằng sinh trắc học / khuôn mặt
  void _loginWithFaceID() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (canCheck) {
        bool authenticated = await _auth.authenticate(
          localizedReason: 'Quét khuôn mặt/vân tay để đăng nhập hệ thống',
          options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
        );
        if (authenticated) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xác thực khuôn mặt thành công!")));
          // Vào thẳng giao diện Phụ huynh (Parent)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ParentDashboard(parentId: 1, email: "parent.faceid@gmail.com")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thiết bị không hỗ trợ Sinh trắc học.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khuôn mặt: $e")));
    }
  }

  void _handleSubmit() async {
    setState(() => _isLoading = true);

    if (_isLoginMode) {
      if (!_isOtpStep) {
        // Bước 1: Đăng nhập Email + Pass
        var res = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
        setState(() => _isLoading = false);

        if (res['success'] != false && res['email'] != null) {
          setState(() {
            _isOtpStep = true;
            if (res['demoOtp'] != null) _otpCtrl.text = res['demoOtp']; // Gợi ý mã OTP từ C# backend
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP đã được gửi về email của bạn!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Sai email hoặc mật khẩu.")));
        }
      } else {
        // Bước 2: Xác thực mã OTP 6 số
        var res = await ApiService.verifyOtp(_emailCtrl.text.trim(), _otpCtrl.text.trim());
        setState(() => _isLoading = false);

        if (res['success'] == true) {
          int userId = res['userId'] ?? 1;
          String role = res['role'] ?? "Parent";
          String email = res['email'] ?? _emailCtrl.text;

          // Yêu cầu 3: Phân quyền chuyển hướng giao diện chuẩn xác
          if (role == "Admin") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          } else if (role == "Staff") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ParentDashboard(parentId: userId, email: email)));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Mã OTP không hợp lệ.")));
        }
      }
    } else {
      // Yêu cầu 1: Đăng ký tài khoản
      var res = await ApiService.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim(), _selectedRole);
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")));
        setState(() {
          _isLoginMode = true;
          _isOtpStep = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Đăng ký thất bại.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 60, color: Colors.indigo),
                  const SizedBox(height: 10),
                  Text(
                    _isLoginMode ? "ĐĂNG NHẬP HỆ THỐNG" : "ĐĂNG KÝ TÀI KHOẢN",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 20),
                  if (!_isLoginMode) ...[
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    // Khắc phục lỗi tràn viền 2.4 pixels bằng cách bọc Row + Expanded bên ngoài DropdownButtonFormField
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            isExpanded: true, // Giúp text dài tự co giãn an toàn bên trong dropdown
                            items: const [
                              DropdownMenuItem(value: "Parent", child: Text("Phụ huynh (Parent)")),
                              DropdownMenuItem(value: "Staff", child: Text("Nhân viên (Staff)")),
                              DropdownMenuItem(value: "Admin", child: Text("Quản trị (Admin)")),
                            ],
                            onChanged: (val) => setState(() => _selectedRole = val!),
                            decoration: const InputDecoration(
                              labelText: 'Vai trò phân quyền',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _emailCtrl,
                    enabled: !_isOtpStep,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passCtrl,
                    enabled: !_isOtpStep,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  ),
                  if (_isOtpStep) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nhập mã OTP (6 số từ email)',
                        prefixIcon: Icon(Icons.pin),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      onPressed: _handleSubmit,
                      child: Text(_isLoginMode ? (_isOtpStep ? "XÁC THỰC OTP & ĐĂNG NHẬP" : "TIẾP TỤC (NHẬN OTP)") : "ĐĂNG KÝ TÀI KHOẢN"),
                    ),
                  ),
                  if (_isLoginMode && !_isOtpStep) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loginWithFaceID,
                      icon: const Icon(Icons.face, color: Colors.indigo),
                      label: const Text("Đăng nhập bằng Khuôn mặt"),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLoginMode = !_isLoginMode;
                      _isOtpStep = false;
                    }),
                    child: Text(_isLoginMode ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Quay lại Đăng nhập"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}