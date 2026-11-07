import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'cloudinary_config.dart';

class UploadedImage {
  const UploadedImage({required this.url, required this.publicId});
  final String url;
  final String publicId;
}

class CloudinaryMediaRepository {
  CloudinaryMediaRepository({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<UploadedImage> uploadImage({required String filePath, required String folder}) async {
    if (!CloudinaryConfig.isConfigured) {
      throw StateError('Cloudinary is not configured yet. Set the cloud name and unsigned preset in cloudinary_config.dart.');
    }
    final file = File(filePath);
    if (!await file.exists()) throw StateError('The selected image is no longer available.');
    if (await file.length() > 5 * 1024 * 1024) throw StateError('Choose an image smaller than 5 MB.');
    final uri = Uri.https('api.cloudinary.com', '/v1_1/' + CloudinaryConfig.cloudName + '/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.unsignedUploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await _client.send(request).timeout(const Duration(seconds: 60));
    final body = await streamed.stream.bytesToString();
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final error = decoded['error'] as Map<String, dynamic>?;
      throw StateError(error?['message'] as String? ?? 'Cloudinary image upload failed.');
    }
    final url = decoded['secure_url'] as String?;
    final publicId = decoded['public_id'] as String?;
    if (url == null || publicId == null) throw StateError('Cloudinary returned an incomplete image response.');
    return UploadedImage(url: url, publicId: publicId);
  }

  void dispose() => _client.close();
}