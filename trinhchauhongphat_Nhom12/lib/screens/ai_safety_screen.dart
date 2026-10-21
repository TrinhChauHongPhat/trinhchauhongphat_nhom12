import 'package:flutter/material.dart';

class AiSafetyScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onNotificationCreated;

  const AiSafetyScreen({
    Key? key,
    this.onNotificationCreated,
  }) : super(key: key);

  @override
  _AiSafetyScreenState createState() => _AiSafetyScreenState();
}

class _AiSafetyScreenState extends State<AiSafetyScreen> {
  bool _aiMode = true;
  bool _autoLockStudy = false;
  String _studyLockDuration = "1 giờ";

  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _testLogs = [];

  // Danh sách từ khóa nguy hiểm để AI nhận diện
  final List<String> _dangerKeywords = [
    "cướp", "trộm", "bắt cóc", "cứu", "khẩn cấp", "bắt nạt", "nguy hiểm", 
    "web cấm", "đánh", "bạo lực", "sos", "help", "sợ", "bị đánh", "kẻ lạ",
    "tai nạn", "cấp cứu", "đuổi theo", "đe dọa", "mất tích", "bị giật",
    "bị đe dọa", "bị theo dõi", "bị ép", "bị ép buộc", "bị lạc", "lạc đường"
  ];

  void _analyzeAndSend(String text) {
    if (text.trim().isEmpty) return;

    if (!_aiMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tính năng AI đang TẮT. Hãy bật công tắc 'AI Phân tích tin nhắn' ở trên để kiểm tra."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String lowerText = text.toLowerCase();
    String? matchedKeyword;

    for (var kw in _dangerKeywords) {
      if (lowerText.contains(kw)) {
        matchedKeyword = kw;
        break;
      }
    }

    DateTime now = DateTime.now();
    String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    if (matchedKeyword != null) {
      // Báo về Trung tâm Thông báo của Phụ huynh
      final newNotif = {
        "id": DateTime.now().millisecondsSinceEpoch,
        "title": "🚨 Cảnh báo AI Bảo Vệ",
        "message": "Phát hiện từ khóa '$matchedKeyword' trong tin nhắn: \"$text\"",
        "time": "Vừa xong",
        "type": "warning",
        "isRead": false,
      };

      if (widget.onNotificationCreated != null) {
        widget.onNotificationCreated!(newNotif);
      }

      // Phát hiện từ khóa nguy hiểm!
      setState(() {
        _testLogs.insert(0, {
          "text": text,
          "isAlert": true,
          "keyword": matchedKeyword,
          "time": timeStr,
        });
      });

      _showEmergencyAlertDialog(text, matchedKeyword);
    } else {
      // Tin nhắn an toàn
      setState(() {
        _testLogs.insert(0, {
          "text": text,
          "isAlert": false,
          "keyword": null,
          "time": timeStr,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(" Tin nhắn an toàn: '$text'\nAI không phát hiện từ khóa nguy hiểm."),
          backgroundColor: Colors.green[700],
        ),
      );
    }

    _msgController.clear();
  }

  void _showEmergencyAlertDialog(String message, String keyword) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "CẢNH BÁO AI NGUY HIỂM!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hệ thống AI vừa phát hiện từ khóa nguy hiểm trong tin nhắn của trẻ:",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nội dung: \"$message\"", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("Từ khóa kích hoạt: '$keyword'", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Hệ thống đã tự động lưu cảnh báo vào Trung tâm Thông báo của Phụ huynh!",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ĐÃ HIỂU & ĐÓNG"),
          ),
        ],
      ),
    );
  }

  void _triggerSosEmergency() {
    final newNotif = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "title": "🚨 BÁO ĐỘNG KHẨN CẤP (SOS)",
      "message": "Trẻ vừa kích hoạt tín hiệu SOS khẩn cấp từ màn hình AI Bảo Vệ!",
      "time": "Vừa xong",
      "type": "warning",
      "isRead": false,
    };

    if (widget.onNotificationCreated != null) {
      widget.onNotificationCreated!(newNotif);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sos, color: Colors.red, size: 36),
            SizedBox(width: 8),
            Text("TÍN HIỆU SOS KHẨN CẤP", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_alert, size: 60, color: Colors.red),
            SizedBox(height: 12),
            Text(
              "Tín hiệu SOS khẩn cấp đã được kích hoạt!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Cảnh báo khẩn cấp đã được gửi trực tiếp đến Trung tâm Thông báo của Phụ huynh.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("TẮT BÁO ĐỘNG SOS"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Smart Safety Guard"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Giới Thiệu
            Card(
              color: Colors.purple[50],
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome, size: 48, color: Colors.purple),
                    SizedBox(height: 8),
                    Text(
                      "Tính năng bảo vệ thông minh AI",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tự động quét từ khóa bạo lực/nguy hiểm trong tin nhắn và tự động khóa ứng dụng giải trí giờ học.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nút Bật/Tắt AI
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("AI Phân tích tin nhắn & Cảnh báo khẩn", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Phát hiện từ khóa bạo lực, bắt nạt, khẩn cấp"),
                    value: _aiMode,
                    activeThumbColor: Colors.purple,
                    onChanged: (val) => setState(() => _aiMode = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text("Tự động khóa app giờ học", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Chặn TikTok, Facebook khi làm bài tập"),
                    value: _autoLockStudy,
                    activeThumbColor: Colors.purple,
                    onChanged: (val) => setState(() => _autoLockStudy = val),
                  ),
                  if (_autoLockStudy) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Thời gian khóa tự động:", style: TextStyle(fontWeight: FontWeight.w500)),
                          DropdownButton<String>(
                            value: _studyLockDuration,
                            items: const [
                              DropdownMenuItem(value: "30 phút", child: Text("30 phút")),
                              DropdownMenuItem(value: "1 giờ", child: Text("1 giờ")),
                              DropdownMenuItem(value: "2 giờ", child: Text("2 giờ")),
                              DropdownMenuItem(value: "19h - 21h", child: Text("19h - 21h")),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _studyLockDuration = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Báo Động SOS Khẩn Cấp
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              onPressed: _triggerSosEmergency,
              icon: const Icon(Icons.sos, size: 28),
              label: const Text(
                "GỬI BÁO ĐỘNG SOS KHẨN CẤP",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // KHU VỰC THỬ NGHIỆM GIẢ LẬP TIN NHẮN (TEST SIMULATOR)
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
                        Icon(Icons.bug_report, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          "Trình giả lập thử nghiệm tin nhắn AI",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Nhập tin nhắn bất kỳ hoặc bấm nút mẫu bên dưới để kiểm tra khả năng nhận diện của AI:",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Mẫu câu có sẵn để bấm test 1-click
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.warning, color: Colors.red, size: 16),
                          label: const Text("Con bị cướp!"),
                          backgroundColor: Colors.red[50],
                          onPressed: () => _analyzeAndSend("Mẹ ơi con bị cướp điện thoại khẩn cấp!"),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                          label: const Text("Cứu con với!"),
                          backgroundColor: Colors.red[50],
                          onPressed: () => _analyzeAndSend("Cứu con với! Bị bạn đánh ở trường"),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.error, color: Colors.orange, size: 16),
                          label: const Text("Bị bắt nạt"),
                          backgroundColor: Colors.orange[50],
                          onPressed: () => _analyzeAndSend("Có người dọa bắt nạt con khẩn cấp"),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          label: const Text("Tin nhắn an toàn"),
                          backgroundColor: Colors.green[50],
                          onPressed: () => _analyzeAndSend("Hôm nay con học bài đạt điểm 10"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Khung gõ tin nhắn tùy chỉnh
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: "Nhập tin nhắn thử nghiệm...",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: _analyzeAndSend,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () => _analyzeAndSend(_msgController.text),
                          child: const Text("KIỂM TRA"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Lịch sử kiểm tra tin nhắn
            if (_testLogs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Lịch sử phân tích tin nhắn vừa test:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _testLogs.length,
                itemBuilder: (context, index) {
                  var log = _testLogs[index];
                  bool isAlert = log['isAlert'];

                  return Card(
                    color: isAlert ? Colors.red[50] : Colors.green[50],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isAlert ? Icons.warning : Icons.check_circle,
                        color: isAlert ? Colors.red : Colors.green,
                      ),
                      title: Text(
                        "\"${log['text']}\"",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isAlert ? Colors.red[900] : Colors.green[900]),
                      ),
                      subtitle: Text(
                        isAlert ? "Từ khóa phát hiện: '${log['keyword']}' • ${log['time']}" : "An toàn • ${log['time']}",
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
