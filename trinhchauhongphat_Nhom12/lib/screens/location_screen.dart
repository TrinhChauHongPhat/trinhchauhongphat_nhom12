import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class LocationScreen extends StatefulWidget {
  final int deviceId;
  final String? childName;

  const LocationScreen({
    Key? key,
    required this.deviceId,
    this.childName,
  }) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _status = "Đang kết nối vệ tinh GPS...";
  double? _lat, _lng;
  double? _accuracy;
  double? _altitude;
  String? _lastUpdatedTime;
  bool _isLoading = false;
  bool _isAutoTracking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateGPS();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Lấy vị trí GPS thực tế từ thiết bị & đồng bộ lên Server
  Future<void> _updateGPS() async {
    setState(() {
      _isLoading = true;
      _status = "Đang xác định vị trí vệ tinh GPS...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _status = "Dịch vụ định vị GPS đang tắt. Vui lòng bật GPS trên thiết bị.";
            _isLoading = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _status = "Quyền truy cập GPS bị từ chối.";
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _status = "Quyền GPS bị từ chối vĩnh viễn. Vui lòng mở Cài đặt ứng dụng để cấp quyền.";
            _isLoading = false;
          });
        }
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      bool ok = await ApiService.updateLocation(widget.deviceId, pos.latitude, pos.longitude);

      DateTime now = DateTime.now();
      String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
          _accuracy = pos.accuracy;
          _altitude = pos.altitude;
          _lastUpdatedTime = timeStr;
          _status = ok ? "Đã đồng bộ tọa độ lên Server thành công!" : "Lưu tọa độ lên Server thất bại.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Lỗi định vị GPS: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Lấy vị trí đã lưu từ Server
  Future<void> _fetchServerLocation() async {
    setState(() {
      _isLoading = true;
      _status = "Đang tải vị trí từ Server...";
    });

    var data = await ApiService.getLocation(widget.deviceId);

    if (data != null && data['latitude'] != null && data['longitude'] != null) {
      setState(() {
        _lat = (data['latitude'] as num).toDouble();
        _lng = (data['longitude'] as num).toDouble();
        _lastUpdatedTime = data['updatedAt'] ?? "Mới đây";
        _status = "Đã lấy tọa độ từ Server thành công!";
        _isLoading = false;
      });
    } else {
      setState(() {
        _status = "Chưa có dữ liệu vị trí trên Server cho thiết bị này.";
        _isLoading = false;
      });
    }
  }

  // Bật/tắt tự động đồng bộ mỗi 10 giây
  void _toggleAutoTracking(bool enabled) {
    setState(() => _isAutoTracking = enabled);

    _timer?.cancel();
    if (enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã bật chế độ tự động đồng bộ GPS mỗi 10 giây")),
      );
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        _updateGPS();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã tắt chế độ tự động đồng bộ GPS")),
      );
    }
  }

  // Sao chép liên kết Google Maps vào Clipboard
  void _copyMapsLink() {
    if (_lat != null && _lng != null) {
      String link = "https://www.google.com/maps/search/?api=1&query=$_lat,$_lng";
      Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã sao chép liên kết Google Maps:\n$link"),
          action: SnackBarAction(label: "ĐÓNG", onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.childName != null
        ? "Định Vị GPS (${widget.childName})"
        : "Chia Sẻ & Giám Sát Vị Trí";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: "Tải từ Server",
            onPressed: _fetchServerLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Cập nhật GPS",
            onPressed: _updateGPS,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card Header
            Card(
              elevation: 4,
              color: Colors.teal[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.my_location, size: 70, color: Colors.teal),
                        if (_isLoading)
                          const SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 3),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _status.contains("thành công") ? Colors.teal[800] : Colors.red[800],
                      ),
                    ),
                    if (_lastUpdatedTime != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Thời gian cập nhật: $_lastUpdatedTime",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coordinates Display
            if (_lat != null && _lng != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text("Tọa Độ Hiện Tại", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Vĩ độ (Latitude):", style: TextStyle(fontWeight: FontWeight.w500)),
                          SelectableText("$_lat", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kinh độ (Longitude):", style: TextStyle(fontWeight: FontWeight.w500)),
                          SelectableText("$_lng", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                      if (_accuracy != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Độ chính xác:", style: TextStyle(fontWeight: FontWeight.w500)),
                            Text("±${_accuracy!.toStringAsFixed(1)} mét", style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ],
                      if (_altitude != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Độ cao:", style: TextStyle(fontWeight: FontWeight.w500)),
                            Text("${_altitude!.toStringAsFixed(1)} m so với mực nước biển", style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _copyMapsLink,
                          icon: const Icon(Icons.map, color: Colors.teal),
                          label: const Text("SAO CHÉP LIÊN KẾT GOOGLE MAPS"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Auto Tracking Switch Tile
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text("Tự động đồng bộ GPS liên tục", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Tự động cập nhật tọa độ thiết bị lên Server mỗi 10 giây"),
                value: _isAutoTracking,
                activeThumbColor: Colors.teal,
                onChanged: _toggleAutoTracking,
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading ? null : _updateGPS,
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text("CẬP NHẬT GPS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading ? null : _fetchServerLocation,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text("TẢI TỪ SERVER"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
