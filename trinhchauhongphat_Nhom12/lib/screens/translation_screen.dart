import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  File? _image;
  String _extractedText = "Chưa có văn bản được quét.";
  String _translatedText = "Bản dịch sẽ hiển thị ở đây.";
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final GoogleTranslator _translator = GoogleTranslator();

  // Hàm chọn ảnh từ thư viện hoặc chụp ảnh mới
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _processImage(_image!);
    }
  }

  // Hàm xử lý OCR (nhận diện chữ) và dịch thuật
  Future<void> _processImage(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      if (rawText.isEmpty) {
        setState(() {
          _extractedText = "Không tìm thấy văn bản nào trong ảnh.";
          _translatedText = "";
          _isLoading = false;
        });
        return;
      }

      // Dịch sang tiếng Việt
      Translation translation = await _translator.translate(rawText, from: 'auto', to: 'vi');

      setState(() {
        _extractedText = rawText;
        _translatedText = translation.text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _extractedText = "Lỗi khi xử lý ảnh: $e";
        _translatedText = "";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dịch Văn Bản từ Ảnh (AI OCR)"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Khu vực hiển thị ảnh
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _image == null
                  ? const Center(child: Text("Chưa chọn ảnh nào", style: TextStyle(color: Colors.grey)))
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // Nút chụp ảnh hoặc chọn từ thư viện
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Chụp ảnh"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Chọn từ thư viện"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Box hiển thị văn bản gốc quét được
                  const Text("Văn bản gốc nhận diện:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(_extractedText, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 16),

                  // Box hiển thị bản dịch
                  const Text("Bản dịch tiếng Việt:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(_translatedText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}