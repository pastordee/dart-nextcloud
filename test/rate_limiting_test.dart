import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import '../lib/src/network.dart';

void main() {
  group('Rate Limiting Tests', () {
    test('RequestException should handle rate limiting properties', () {
      // Test rate limiting exception
      final rateLimitException = RequestException(
        'Too Many Requests',
        429,
        'https://example.com/api',
        'GET',
        retryAfter: 60,
      );

      expect(rateLimitException.isRateLimited, isTrue);
      expect(rateLimitException.isRetryable, isTrue);
      expect(rateLimitException.retryAfter, equals(60));
      expect(
        rateLimitException.toString(),
        contains('Rate limited (too many requests) - retry after 60s'),
      );
    });

    test('RequestException should identify retryable errors', () {
      // Test 500 error (retryable)
      final serverError = RequestException(
        'Internal Server Error',
        500,
        'https://example.com/api',
        'GET',
      );

      expect(serverError.isRateLimited, isFalse);
      expect(serverError.isRetryable, isTrue);

      // Test 404 error (not retryable)
      final notFoundError = RequestException(
        'Not Found',
        404,
        'https://example.com/api',
        'GET',
      );

      expect(notFoundError.isRateLimited, isFalse);
      expect(notFoundError.isRetryable, isFalse);
    });

    test('parseRetryAfter should handle different formats', () {
      // Test seconds format
      expect(Network.parseRetryAfter('60'), equals(60));
      expect(Network.parseRetryAfter('120'), equals(120));

      // Test invalid formats
      expect(Network.parseRetryAfter('invalid'), isNull);
      expect(Network.parseRetryAfter(null), isNull);
    });

    test('calculateRetryDelay should respect retry-after header', () {
      final network = Network(http.Client());

      // When retry-after is specified, it should be used
      final delayWithRetryAfter = network.calculateRetryDelay(0, 30);
      expect(delayWithRetryAfter, equals(30000)); // 30 seconds in milliseconds

      // When retry-after is not specified, use exponential backoff
      final delayWithoutRetryAfter = network.calculateRetryDelay(0, null);
      expect(delayWithoutRetryAfter, greaterThan(500)); // Should have some delay
      expect(delayWithoutRetryAfter, lessThan(2000)); // But not too much for first attempt
    });

    test('calculateRetryDelay should use exponential backoff', () {
      final network = Network(http.Client(), baseRetryDelay: 1000);

      final delay1 = network.calculateRetryDelay(0, null);
      final delay2 = network.calculateRetryDelay(1, null);
      final delay3 = network.calculateRetryDelay(2, null);

      // Each delay should be roughly double the previous (with jitter)
      expect(delay2, greaterThan(delay1));
      expect(delay3, greaterThan(delay2));
    });
  });
}
