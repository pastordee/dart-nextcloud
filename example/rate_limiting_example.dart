import 'package:nextcloud/nextcloud.dart';

/// Example demonstrating how to handle rate limiting with the Nextcloud client
void main() async {
  // Create a Nextcloud client
  final client = NextCloudClient.withCredentials(
    Uri.parse('https://files.prayercircle.co.uk'),
    'admin',
    'roshuq-zabcuc-9tijNa',
  );

  try {
    // This example shows how rate limiting is automatically handled
    print('Performing multiple operations that might trigger rate limiting...');
    
    // These operations will automatically retry if they encounter HTTP 429 errors
    await client.shares.getShares();
    await client.user.getUser();
    
    print('Operations completed successfully!');
    
  } on RequestException catch (e) {
    // Handle rate limiting and other HTTP errors
    if (e.isRateLimited) {
      print('Rate limited! Server requested retry after ${e.retryAfter} seconds');
      print('The client automatically retried, but all attempts failed.');
    } else if (e.isRetryable) {
      print('Server error (${e.statusCode}): $e');
      print('The client automatically retried, but all attempts failed.');
    } else {
      print('Non-retryable error: $e');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}

/// Example of configuring custom rate limiting behavior
void customRateLimitingExample() {
  // The Network class supports custom retry configuration
  // However, this is not directly exposed through the public API
  // In the future, this could be exposed through NextCloudClient constructor
  
  print('''
Rate Limiting Features:

1. Automatic Retry: The client automatically retries rate-limited requests (HTTP 429)
2. Exponential Backoff: Retry delays increase exponentially (1s, 2s, 4s, etc.)
3. Respect Server Headers: Honors "Retry-After" headers from the server
4. Jitter: Adds randomization to prevent thundering herd problems
5. Max Attempts: Limits retries to prevent infinite loops (default: 3)

Error Types:
- Rate Limited (429): Automatically retried with exponential backoff
- Server Errors (5xx): Automatically retried as they may be temporary
- Client Errors (4xx): Not retried as they indicate permanent issues

Usage Tips:
- The client handles rate limiting transparently
- Monitor RequestException.isRateLimited for rate limit detection
- Use RequestException.retryAfter to see server-suggested delays
- Consider implementing application-level backoff for bulk operations
''');
}
