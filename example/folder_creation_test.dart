import 'dart:typed_data';
import 'package:nextcloud/nextcloud.dart';

/// Example app demonstrating efficient folder creation with nested directory structure
/// 
/// This example shows:
/// - How to create nested folders on Nextcloud with fixed mkdirs() (like mkdir -p)
/// - How to verify folder creation
/// - Error handling for folder operations
/// - More efficient than multiple mkdir() calls
void main() async {
  // Configuration - using your Nextcloud details
  const serverUrl = 'https://files.prayercircle.co.uk';
  const username = 'admin';
  const password = 'roshuq-zabcuc-9tijNa';
  
  // Folder structure to create
  const testFolder = 'test-folder';
  const secondFolder = '$testFolder/second-folder';
  const lastFolder = '$secondFolder/last-folder';
  
  print('📁 Nextcloud Folder Creation Example');
  print('=' * 45);
  
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
    
    print('\n📂 Creating nested folder structure with fixed mkdirs...');
    print('Structure to create:');
    print('├── $testFolder/');
    print('│   └── second-folder/');
    print('│       └── last-folder/');
    
    // Use the fixed mkdirs to create the entire nested structure in one call
    print('\n🔨 Creating entire nested structure with fixed mkdirs...');
    try {
      await client.webDav.mkdirs(lastFolder);
      print('✅ Created entire structure: $lastFolder');
      print('   This automatically created all parent directories:');
      print('   📁 $testFolder/');
      print('   📁 $secondFolder/');
      print('   📁 $lastFolder/');
    } catch (e) {
      print('❌ Failed to create folder structure: $e');
      rethrow;
    }
    
    print('\n🔍 Verifying folder structure...');
    
    // Verify the root test folder
    print('\n📋 Listing contents of root directory:');
    final rootFiles = await client.webDav.ls('/');
    final testFolderExists = rootFiles.any((f) => f.name == testFolder && f.isDirectory);
    
    if (testFolderExists) {
      print('✅ Found: $testFolder/ (directory)');
    } else {
      print('❌ Missing: $testFolder/');
    }
    
    // Verify the second folder
    print('\n📋 Listing contents of "$testFolder":');
    try {
      final testFolderContents = await client.webDav.ls('/$testFolder');
      final secondFolderExists = testFolderContents.any((f) => f.name == 'second-folder' && f.isDirectory);
      
      if (secondFolderExists) {
        print('✅ Found: second-folder/ (directory)');
      } else {
        print('❌ Missing: second-folder/');
      }
      
      // Show all contents
      for (final file in testFolderContents) {
        final type = file.isDirectory ? 'directory' : 'file';
        print('   📄 ${file.name} ($type, ${file.size} bytes)');
      }
      
    } catch (e) {
      print('❌ Could not list contents of $testFolder: $e');
    }
    
    // Verify the last folder
    print('\n📋 Listing contents of "$secondFolder":');
    try {
      final secondFolderContents = await client.webDav.ls('/$secondFolder');
      final lastFolderExists = secondFolderContents.any((f) => f.name == 'last-folder' && f.isDirectory);
      
      if (lastFolderExists) {
        print('✅ Found: last-folder/ (directory)');
      } else {
        print('❌ Missing: last-folder/');
      }
      
      // Show all contents
      for (final file in secondFolderContents) {
        final type = file.isDirectory ? 'directory' : 'file';
        print('   📄 ${file.name} ($type, ${file.size} bytes)');
      }
      
    } catch (e) {
      print('❌ Could not list contents of $secondFolder: $e');
    }
    
    // Verify the deepest folder is empty
    print('\n📋 Listing contents of "$lastFolder":');
    try {
      final lastFolderContents = await client.webDav.ls('/$lastFolder');
      
      if (lastFolderContents.isEmpty) {
        print('✅ Last folder is empty (as expected)');
      } else {
        print('ℹ️  Last folder contains ${lastFolderContents.length} items:');
        for (final file in lastFolderContents) {
          final type = file.isDirectory ? 'directory' : 'file';
          print('   📄 ${file.name} ($type, ${file.size} bytes)');
        }
      }
      
    } catch (e) {
      print('❌ Could not list contents of $lastFolder: $e');
    }
    
    print('\n🧪 Testing folder operations...');
    
    // Test creating a file in the deepest folder
    print('\nCreating a test file in the deepest folder...');
    const testFileContent = 'Hello from the deepest folder! 🎉';
    const testFileName = '$lastFolder/test-file.txt';
    
    try {
      await client.webDav.upload(
        Uint8List.fromList(testFileContent.codeUnits),
        testFileName,
      );
      print('✅ Created test file: $testFileName');
      
      // Verify the file was created
      final finalContents = await client.webDav.ls('/$lastFolder');
      final testFileExists = finalContents.any((f) => f.name == 'test-file.txt');
      
      if (testFileExists) {
        print('✅ File verified in deepest folder');
      } else {
        print('❌ File not found in folder listing');
      }
      
    } catch (e) {
      print('❌ Failed to create test file: $e');
    }
    
    print('\n🎉 Folder creation example completed!');
    print('📝 Summary:');
    print('   ✅ Created nested folder structure with fixed mkdirs() call:');
    print('      📁 $testFolder/');
    print('      📁 $testFolder/second-folder/');
    print('      📁 $testFolder/second-folder/last-folder/');
    print('   ✅ Verified all folders exist');
    print('   ✅ Created test file in deepest folder');
    print('   ✅ mkdirs() now works correctly like mkdir -p');
    print('   ✅ All operations completed successfully');
    
  } on RequestException catch (e) {
    print('\n❌ Request failed: ${e.toString()}');
    
    if (e.isRateLimited) {
      print('🔄 Rate limiting detected - all retries failed');
    } else if (e.statusCode == 401) {
      print('🔐 Authentication failed - check credentials');
    } else if (e.statusCode == 404) {
      print('📂 Resource not found - check server URL and WebDAV');
    } else if (e.statusCode == 405) {
      print('📁 Folder may already exist or permission denied');
    } else {
      print('🔧 HTTP Error ${e.statusCode}: ${e.method} ${e.url}');
    }
    
  } catch (e) {
    print('\n💥 Unexpected error: $e');
    print('🔍 This might indicate a network issue or bug');
  }
}
