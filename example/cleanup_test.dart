import 'package:nextcloud/nextcloud.dart';

/// Quick cleanup script to delete test folders before testing mkdirs fix
void main() async {
  const serverUrl = 'https://files.prayercircle.co.uk';
  const username = 'admin';
  const password = 'roshuq-zabcuc-9tijNa';
  
  print('🧹 Cleaning up test folders...');
  
  final client = NextCloudClient.withCredentials(
    Uri.parse(serverUrl),
    username,
    password,
  );
  
  try {
    // Delete the test folder (this will delete the entire nested structure)
    await client.webDav.delete('test-folder');
    print('✅ Deleted test-folder and all contents');
  } catch (e) {
    if (e.toString().contains('404')) {
      print('ℹ️  test-folder does not exist (already clean)');
    } else {
      print('❌ Failed to delete test-folder: $e');
    }
  }
  
  print('🎉 Cleanup completed!');
}
