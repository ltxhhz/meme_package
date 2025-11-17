import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 调用 Umi-OCR 本地识别接口，返回识别文本
Future<String> recognizeText(File imageFile) async {
  // 读取图片并编码为 Base64
  final imageBytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(imageBytes);

  // 构造请求体
  final requestBody = jsonEncode({
    "base64": base64Image,
    "options": {
      "data.format": "text"
    }
  });

  // 发起 POST 请求
  final response = await http
      .post(
        Uri.parse("http://127.0.0.1:1224/api/ocr"),
        headers: {
          "Content-Type": "application/json"
        },
        body: requestBody,
      )
      .timeout(Duration(seconds: 10));

  // 解析响应
  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    if (result["code"] == 100) {
      return result["data"] as String;
    } else if (result["code"] == 101) {
      return "";
    } else {
      throw Exception("识别失败: ${result["data"]}");
    }
  } else {
    throw Exception("请求失败: ${response.statusCode}");
  }
}
