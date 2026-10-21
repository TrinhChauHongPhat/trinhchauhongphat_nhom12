import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'location_screen.dart';
import 'ai_safety_screen.dart';
import 'translation_screen.dart'; // Import màn hình Dịch thuật (Tính năng f)
import 'auth_screen.dart';

class ParentDashboard extends StatefulWidget {
  final int parentId;
  final String email;
  const ParentDashboard({Key? key, required this.parentId, required this.email}) : super(key: key);

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  List<dynamic> _kids = [];
  bool _isLoading = true;
  final _nameCtrl = TextEditingController();
  final Map<int, String> _deviceLockDurations = {};

  // Danh sách thông báo mẫu của hệ thống MDM
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "title": "Cảnh báo AI Bảo Vệ",
      "message": "Phát hiện từ khóa nhạy cảm trong ứng dụng trên máy con.",
      "time": "10 phút trước",
      "type": "warning",
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Đồng bộ Vị trí GPS",
      "message": "Tọa độ vị trí mới nhất của thiết bị đã được lưu lên máy chủ.",
      "time": "25 phút trước",
      "type": "info",
      "isRead": false,
    },
    {
      "id": 3,
      "title": "Chế độ Khóa Học Tập",
      "message": "Tự động khóa ứng dụng giải trí theo thời khóa biểu học tập.",
      "time": "1 giờ trước",
      "type": "success",
      "isRead": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadKids();
  }

  void _loadKids() async {
    setState(() => _isLoading = true);
    var data = await ApiService.getMyKids(widget.parentId);
    setState(() {
      _kids = data;
      _isLoading = false;
    });
  }

  // Mở Trung tâm Thông báo
  void _showNotificationCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            int unreadCount = _notifications.where((n) => !n['isRead']).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh Tiêu Đề Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.indigo, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            "Trung Tâm Thông Báo",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$unreadCount mới",
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tổng số: ${_notifications.length} thông báo",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      if (unreadCount > 0)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              for (var n in _notifications) {
                                n['isRead'] = true;
                              }
                            });
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text("Đánh dấu tất cả đã đọc", style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Danh sách thông báo
                  Expanded(
                    child: _notifications.isEmpty
                        ? const Center(
                            child: Text("Không có thông báo nào."),
                          )
                        : ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              var notif = _notifications[index];
                              bool isRead = notif['isRead'];

                              IconData iconData;
                              Color iconColor;
                              Color bgColor;

                              if (notif['type'] == 'warning') {
                                iconData = Icons.warning_amber_rounded;
                                iconColor = Colors.orange[800]!;
                                bgColor = Colors.orange[50]!;
                              } else if (notif['type'] == 'info') {
                                iconData = Icons.location_on;
                                iconColor = Colors.teal;
                                bgColor = Colors.teal[50]!;
                              } else {
                                iconData = Icons.security;
                                iconColor = Colors.green[700]!;
                                bgColor = Colors.green[50]!;
                              }

                              return Card(
                                color: isRead ? Colors.white : bgColor,
                                elevation: isRead ? 1 : 3,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isRead ? Colors.grey.shade200 : iconColor.withAlpha(128),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: iconColor.withAlpha(50),
                                    child: Icon(iconData, color: iconColor),
                                  ),
                                  title: Text(
                                    notif['title'],
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(notif['message']),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif['time'],
                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      notif['isRead'] = true;
                                    });
                                    setModalState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã đăng xuất thành công!")),
              );
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  // CREATE (Tạo thiết bị con)
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm thiết bị con mới"),
        content: TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(hintText: "Nhập tên con (Ví dụ: Bé An)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isNotEmpty) {
                bool ok = await ApiService.createChild(widget.parentId, _nameCtrl.text.trim());
                if (ok) {
                  _nameCtrl.clear();
                  Navigator.pop(context);
                  _loadKids();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã thêm thiết bị thành công!")),
                  );
                }
              }
            },
            child: const Text("Thêm"),
          )
        ],
      ),
    );
  }

  // UPDATE (Khóa / Mở khóa thiết bị kèm chọn thời gian khóa)
  void _toggleLock(int deviceId, bool isCurrentlyLocked, String childName) async {
    if (isCurrentlyLocked) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Mở khóa máy $childName?"),
          content: const Text("Xác nhận mở khóa để trẻ có thể sử dụng lại thiết bị bình thường."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                bool ok = await ApiService.toggleLock(deviceId);
                if (ok) {
                  setState(() {
                    _deviceLockDurations.remove(deviceId);
                  });
                  _loadKids();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã mở khóa máy $childName thành công!")),
                    );
                  }
                }
              },
              child: const Text("Mở khóa"),
            ),
          ],
        ),
      );
    } else {
      String selectedDuration = "1 giờ";

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Khóa máy $childName", style: const TextStyle(fontSize: 18))),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn thời gian khóa thiết bị:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<String>(
                    title: const Text("30 phút (Tập trung ngắn)"),
                    value: "30 phút",
                    groupValue: selectedDuration,
                    activeColor: Colors.red,
                    onChanged: (val) => setDialogState(() => selectedDuration = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text("1 giờ (Làm bài tập)"),
                    value: "1 giờ",
                    groupValue: selectedDuration,
                    activeColor: Colors.red,
                    onChanged: (val) => setDialogState(() => selectedDuration = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text("2 giờ (Buổi tối / Giờ ngủ)"),
                    value: "2 giờ",
                    groupValue: selectedDuration,
                    activeColor: Colors.red,
                    onChanged: (val) => setDialogState(() => selectedDuration = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text("Khóa cho đến khi mở lại"),
                    value: "Đến khi mở thủ công",
                    groupValue: selectedDuration,
                    activeColor: Colors.red,
                    onChanged: (val) => setDialogState(() => selectedDuration = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    bool ok = await ApiService.toggleLock(deviceId);
                    if (ok) {
                      setState(() {
                        _deviceLockDurations[deviceId] = selectedDuration;
                      });
                      _loadKids();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã khóa máy $childName ($selectedDuration)!"),
                            backgroundColor: Colors.red[800],
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("XÁC NHẬN KHÓA"),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // DELETE (Xóa thiết bị con)
  void _deleteKid(int deviceId) async {
    bool ok = await ApiService.deleteChild(deviceId);
    if (ok) _loadKids();
  }

  @override
  Widget build(BuildContext context) {
    int unreadNotifCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("KidGuard MDM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.email, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Nút Chuông Thông Báo
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: "Thông báo",
                onPressed: _showNotificationCenter,
              ),
              if (unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      "$unreadNotifCount",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), tooltip: "Làm mới", onPressed: _loadKids),
          IconButton(icon: const Icon(Icons.logout), tooltip: "Đăng xuất", onPressed: _confirmLogout),
        ],
      ),
      body: Column(
        children: [
          // Thanh điều hướng tiện ích nhanh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.indigo[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen(deviceId: 1))),
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text("Giám sát GPS"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslationScreen())),
                    icon: const Icon(Icons.translate, size: 18),
                    label: const Text("Dịch AI / OCR"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiSafetyScreen(
                          onNotificationCreated: (newNotif) {
                            setState(() {
                              _notifications.insert(0, newNotif);
                            });
                          },
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.psychology, size: 18),
                    label: const Text("AI Bảo Vệ"),
                  ),
                ],
              ),
            ),
          ),

          // Header Tiêu Đề Danh Sách
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Danh sách thiết bị con",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_kids.length} thiết bị",
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _kids.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.devices_other, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              "Chưa có thiết bị con nào được kết nối.",
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add),
                              label: const Text("Thêm thiết bị con"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _kids.length,
                        itemBuilder: (context, i) {
                          var kid = _kids[i];
                          bool isLocked = kid['isLocked'] ?? false;
                          String? lockDuration = _deviceLockDurations[kid['deviceId']];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isLocked ? Icons.lock : Icons.phone_android,
                                        color: isLocked ? Colors.red : Colors.green,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          kid['childName'] ?? "Chưa đặt tên",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLocked ? Colors.red[50] : Colors.green[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isLocked ? Colors.red : Colors.green),
                                        ),
                                        child: Text(
                                          isLocked ? 'ĐANG KHÓA' : 'BÌNH THƯỜNG',
                                          style: TextStyle(
                                            color: isLocked ? Colors.red[800] : Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Mã kết nối: ${kid['pairingCode']}",
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                  if (isLocked) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.timer, size: 16, color: Colors.red[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Thời gian khóa: ${lockDuration ?? 'Đến khi mở thủ công'}",
                                          style: TextStyle(color: Colors.red[800], fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LocationScreen(
                                              deviceId: kid['deviceId'],
                                              childName: kid['childName'],
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.location_on, size: 18),
                                        label: const Text("Vị trí GPS"),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(isLocked ? Icons.lock_open : Icons.lock_outline, color: Colors.orange),
                                        tooltip: isLocked ? "Mở khóa máy" : "Khóa máy",
                                        onPressed: () => _toggleLock(kid['deviceId'], isLocked, kid['childName'] ?? "máy con"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: "Xóa thiết bị",
                                        onPressed: () => _deleteKid(kid['deviceId']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text("Thêm máy con"),
      ),
    );
  }
}
