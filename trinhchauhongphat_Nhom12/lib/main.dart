import 'dart:io'; // 👈 1. Thêm import thư viện io
import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

// 👇 2. Khai báo lớp bỏ qua kiểm tra chứng chỉ SSL (giống như Swagger trên PC)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 3. Kích hoạt chế độ bỏ qua lỗi bắt tay bảo mật trước khi chạy app
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kid Guard MDM - Nhóm 12',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}