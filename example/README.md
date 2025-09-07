# Upload Test App

This example demonstrates uploading an image to Nextcloud with progress tracking and automatic rate limiting handling.

## Features Demonstrated

- ✅ **File Upload with Progress**: Real-time upload progress tracking
- ✅ **Rate Limiting**: Automatic retry with exponential backoff for HTTP 429 errors  
- ✅ **Error Handling**: Comprehensive error handling for common scenarios
- ✅ **File Verification**: Upload verification by downloading and comparing
- ✅ **Connection Testing**: Multiple rapid requests to test rate limiting resilience

## Setup

1. **Update Configuration**: Edit `example/upload_test_app.dart` and update these values:
   ```dart
   const serverUrl = 'https://your-nextcloud.com';
   const username = 'your-username';
   const password = 'your-password';
   ```

2. **Ensure Test Image Exists**: The example uses `test/files/test.png`. This file should already exist in the repository.

## Running the Example

```bash
# From the project root directory
cd /path/to/dart-nextcloud

# Run the example
dart run example/upload_test_app.dart
```

## Expected Output

```
🚀 Nextcloud Image Upload Example
========================================
📡 Connecting to Nextcloud server...
✅ Connected as: your-username

📂 Preparing file upload...
📊 File size: 2.3 KB

📤 Starting upload with progress tracking...
📈 Progress: 10% (0.23 MB / 2.30 MB)
📈 Progress: 50% (1.15 MB / 2.30 MB)
📈 Progress: 100% (2.30 MB / 2.30 MB)
✅ Upload completed successfully!
⏱️  Upload time: 543ms
🌐 Remote path: /uploaded-test-image.png

🔍 Verifying upload...
✅ File verified on server:
   📁 Name: uploaded-test-image.png
   📊 Size: 2356 bytes
   📅 Modified: 2025-09-07T10:30:45.000Z

🔄 Testing download...
✅ Download completed - file integrity verified!

🧪 Testing rate limiting resilience...
Making multiple rapid requests to test rate limiting...
✅ Request 1 succeeded
✅ Request 2 succeeded
✅ Request 3 succeeded
✅ Request 4 succeeded
✅ Request 5 succeeded

🎉 Example completed successfully!
📝 Summary:
   - File uploaded with progress tracking
   - Upload verified and downloaded
   - Rate limiting handled automatically
   - All operations completed without manual retry logic
```

## Error Scenarios

The example includes comprehensive error handling for:

- **Rate Limiting (HTTP 429)**: Automatic retry with exponential backoff
- **Authentication Errors (HTTP 401)**: Clear guidance on credentials
- **Not Found (HTTP 404)**: Server/WebDAV configuration issues  
- **File System Errors**: Missing test image file
- **Network Issues**: Connection timeouts and other network problems

## Rate Limiting Details

When rate limiting occurs:
- The client automatically detects HTTP 429 responses
- Retry-After headers are parsed and respected
- Exponential backoff is used (1s → 2s → 4s → etc.)
- Jitter is added to prevent thundering herd problems
- After 3 failed attempts, a descriptive error is thrown

## Security Notes

- Consider using App Passwords instead of your main password
- Store credentials securely (environment variables, secure vault, etc.)
- Be mindful of rate limits when making bulk operations
