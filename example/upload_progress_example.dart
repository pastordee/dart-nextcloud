import 'dart:typed_data';
import 'package:nextcloud/nextcloud.dart';

/// Example demonstrating upload progress monitoring
/// 
/// This example shows how to use the new upload progress callback
/// functionality in the NextCloud WebDAV client.
void uploadWithProgress(NextCloudClient client) async {
  // Create some sample data to upload (1MB of test data)
  final data = Uint8List.fromList(List.generate(1024 * 1024, (i) => i % 256));

  try {
    // Upload with progress monitoring
    await client.webDav.upload(
      data,
      'test-file-with-progress.bin',
      onUploadProgress: (bytesSent, totalBytes) {
        final percentage = (bytesSent / totalBytes * 100).round();
        print('Upload progress: $bytesSent/$totalBytes bytes ($percentage%)');
        
        // You can use this callback to:
        // - Update a progress bar in your UI
        // - Show percentage completion
        // - Display transfer speed calculations
        // - Cancel upload if needed (by throwing an exception)
        
        // Example: Update every 10%
        if (percentage % 10 == 0) {
          print('Reached $percentage% completion');
        }
        
        // Example: Log final completion
        if (bytesSent == totalBytes) {
          print('Upload transfer completed!');
        }
      },
    );
    
    print('Upload operation completed successfully!');
  } catch (e) {
    print('Upload failed: $e');
  }
}

void main() {
  print('This example demonstrates the upload progress feature.');
  print('See the uploadWithProgress() function for usage details.');
  print('Pass your configured NextCloudClient instance to the function.');
}
