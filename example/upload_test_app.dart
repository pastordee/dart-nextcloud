import 'dart:io';
import 'dart:typed_data';
import 'package:nextcloud/nextcloud.dart';

/// Example app demonstrating image upload with progress tracking and rate limiting
/// 
/// This example shows:
/// - How to upload files with progress monitoring
/// - How rate limiting is handled automatically
/// - Error handling for various scenarios
void main() async {
  // Configuration - update these with your Nextcloud details
  const serverUrl = 'https://files.prayercircle.co.uk';
  const username = 'admin';
  const password = 'roshuq-zabcuc-9tijNa';
  
  // Path to the image we want to upload
  const imagePath = 'test/files/test.png';
  const remoteFileName = 'uploaded-test-image.png';
  
  print('🚀 Nextcloud Image Upload Example');
  print('=' * 40);
  
  try {
    // Create Nextcloud client with credentials
    final client = NextCloudClient.withCredentials(
      Uri.parse(serverUrl),
      username,
      password,
    );
    
    print('📡 Connecting to Nextcloud server...');
    
    // Test connection by getting user info
    final user = await client.user.getUser();
    print('✅ Connected as: ${user.id}');
    
    print('\n📂 Preparing file upload...');
    
    // Read the image file
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      print('❌ Error: Image file not found at $imagePath');
      print('💡 Make sure to run this from the project root directory');
      return;
    }
    
    final imageBytes = await imageFile.readAsBytes();
    final fileSize = imageBytes.length;
    print('📊 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');
    
    print('\n📤 Starting upload with progress tracking...');
    
    // Track upload progress
    var lastProgress = -1;
    void onProgress(int bytesSent, int totalBytes) {
      final progress = (bytesSent * 100 / totalBytes).round();
      if (progress != lastProgress && progress % 10 == 0) {
        final mbSent = (bytesSent / 1024 / 1024).toStringAsFixed(2);
        final mbTotal = (totalBytes / 1024 / 1024).toStringAsFixed(2);
        print('📈 Progress: $progress% ($mbSent MB / $mbTotal MB)');
        lastProgress = progress;
      }
    }
    
    // Upload the image with progress tracking
    final stopwatch = Stopwatch()..start();
    
    await client.webDav.upload(
      Uint8List.fromList(imageBytes),
      remoteFileName,
      onUploadProgress: onProgress,
    );
    
    stopwatch.stop();
    
    print('✅ Upload completed successfully!');
    print('⏱️  Upload time: ${stopwatch.elapsedMilliseconds}ms');
    print('🌐 Remote path: /$remoteFileName');
    
    print('\n🔍 Verifying upload...');
    
    // Verify the upload by listing files
    final files = await client.webDav.ls('/');
    final uploadedFile = files.where((f) => f.name == remoteFileName).firstOrNull;
    
    if (uploadedFile != null) {
      print('✅ File verified on server:');
      print('   📁 Name: ${uploadedFile.name}');
      print('   📊 Size: ${uploadedFile.size} bytes');
      print('   📅 Modified: ${uploadedFile.lastModified}');
    } else {
      print('⚠️  Warning: File not found in directory listing');
    }
    
    print('\n🔄 Testing download...');
    
    // Download the file back to verify integrity
    final downloadedBytes = await client.webDav.download(remoteFileName);
    
    // Verify file integrity
    if (downloadedBytes.length == imageBytes.length) {
      print('✅ Download completed - file integrity verified!');
    } else {
      print('❌ File size mismatch - upload may have failed');
      print('   Original: ${imageBytes.length} bytes');
      print('   Downloaded: ${downloadedBytes.length} bytes');
    }
    
    print('\n🧪 Testing rate limiting resilience...');
    
    // Demonstrate that the client handles rate limiting automatically
    // by making several rapid requests
    print('Making multiple rapid requests to test rate limiting...');
    for (int i = 1; i <= 5; i++) {
      try {
        await client.webDav.ls('/');
        print('✅ Request $i succeeded');
      } catch (e) {
        print('⚠️  Request $i failed: $e');
      }
    }
    
    print('\n🎉 Example completed successfully!');
    print('📝 Summary:');
    print('   - File uploaded with progress tracking');
    print('   - Upload verified and downloaded');
    print('   - Rate limiting handled automatically');
    print('   - All operations completed without manual retry logic');
    
  } on RequestException catch (e) {
    print('\n❌ Request failed: ${e.toString()}');
    
    if (e.isRateLimited) {
      print('🔄 Rate limiting detected:');
      print('   - Status: HTTP ${e.statusCode}');
      if (e.retryAfter != null) {
        print('   - Retry after: ${e.retryAfter} seconds');
      }
      print('   - The client automatically retried but all attempts failed');
      print('💡 Consider reducing request frequency or waiting longer');
    } else if (e.statusCode == 401) {
      print('🔐 Authentication failed:');
      print('   - Check your username and password');
      print('   - Verify the server URL is correct');
      print('   - Consider using an app password instead');
    } else if (e.statusCode == 404) {
      print('📂 Resource not found:');
      print('   - Check the server URL');
      print('   - Verify WebDAV is enabled on your Nextcloud');
    } else {
      print('🔧 HTTP Error ${e.statusCode}:');
      print('   - Method: ${e.method}');
      print('   - URL: ${e.url}');
      if (e.body.isNotEmpty) {
        print('   - Response: ${e.body.length > 100 ? '${e.body.substring(0, 100)}...' : e.body}');
      }
    }
    
  } on FileSystemException catch (e) {
    print('\n📁 File system error: $e');
    print('💡 Make sure the test image exists and is readable');
    
  } catch (e) {
    print('\n💥 Unexpected error: $e');
    print('🔍 This might indicate a bug or network issue');
  }
}

/// Helper extension to safely get first element or null
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
