import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName =
      'your_cloud_name'; // Replace with your Cloudinary cloud name
  static const String _uploadPreset =
      'your_upload_preset'; // Replace with your upload preset
  static const String _apiKey =
      'your_api_key'; // Replace with your Cloudinary API key
  static const String _apiSecret =
      'your_api_secret'; // Replace with your Cloudinary API secret

  static Future<String?> uploadImage({
    required XFile imageFile,
    String? folder = 'lead_kart',
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
      );

      // Add fields
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder ?? 'lead_kart';
      request.fields['transformation'] = 'c_fill,w_800,h_800,q_auto';

      // Add file
      var file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(file);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        print('Error uploading to Cloudinary: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  static Future<String?> uploadImageFromFile({
    required File imageFile,
    String? folder = 'lead_kart',
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
      );

      // Add fields
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder ?? 'lead_kart';
      request.fields['transformation'] = 'c_fill,w_800,h_800,q_auto';

      // Add file
      var file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(file);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        print('Error uploading to Cloudinary: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  static String getOptimizedImageUrl(
    String originalUrl, {
    int width = 400,
    int height = 400,
    String crop = 'fill',
    String quality = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    // Parse the URL and add transformation parameters
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;

    if (pathSegments.length >= 3) {
      final cloudName = pathSegments[0];
      final resourceType = pathSegments[1];
      final publicId = pathSegments.sublist(2).join('/');

      return 'https://res.cloudinary.com/$cloudName/$resourceType/upload/c_$crop,w_$width,h_$height,q_$quality/$publicId';
    }

    return originalUrl;
  }

  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
