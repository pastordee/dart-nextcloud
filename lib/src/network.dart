import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:nextcloud/nextcloud.dart';

import 'http_client/http_client.dart';

// ignore: public_member_api_docs, avoid_classes_with_only_static_members
class HttpHeaders {
  // ignore: public_member_api_docs
  static String authorizationHeader = 'authorization';

  // ignore: public_member_api_docs
  static String acceptHeader = 'accept';

  // ignore: public_member_api_docs
  static String contentTypeHeader = 'content-type';

  // ignore: public_member_api_docs
  static String userAgentHeader = 'user-agent';
}

// ignore: public_member_api_docs, avoid_classes_with_only_static_members
class ContentType {
  // ignore: public_member_api_docs
  static final json = _MimeType('application/json');

  // ignore: public_member_api_docs
  static final xml = _MimeType('application/xml');
}

class _MimeType {
  _MimeType(this.value);

  final String value;
}

/// Http client with the correct authentication and header
class NextCloudHttpClient extends HttpClient {
  // ignore: public_member_api_docs
  NextCloudHttpClient(
    this._authString,
    this._defaultHeaders,
    this._inner,
  );

  // ignore: public_member_api_docs
  factory NextCloudHttpClient.defaultClient(
    String authString,
    Map<String, String>? defaultHeaders,
  ) =>
      NextCloudHttpClient(
        authString,
        defaultHeaders,
        HttpClient(),
      );

  /// Constructs a new [NextCloudHttpClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  factory NextCloudHttpClient.withCredentials(
    String username,
    String password, {
    Map<String, String>? defaultHeaders,
  }) =>
      NextCloudHttpClient.defaultClient(
        'Basic ${base64.encode(utf8.encode('$username:$password')).trim()}',
        defaultHeaders,
      );

  /// Constructs a new [NextCloudHttpClient] which will use the provided
  /// [appPassword] for all subsequent requests.
  factory NextCloudHttpClient.withAppPassword(
    String appPassword, {
    Map<String, String>? defaultHeaders,
  }) =>
      NextCloudHttpClient.defaultClient(
        'Bearer $appPassword',
        defaultHeaders,
      );

  /// Constructs a new [NextCloudHttpClient] without login data.
  /// May only be useful for app password login setup
  factory NextCloudHttpClient.withoutLogin({
    Map<String, String>? defaultHeaders,
  }) =>
      NextCloudHttpClient.defaultClient(
        '',
        defaultHeaders,
      );

  final http.Client _inner;
  final String _authString;
  final Map<String, String>? _defaultHeaders;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final coreHeaders = <String, String>{};
    coreHeaders[HttpHeaders.authorizationHeader] = _authString;
    coreHeaders['OCS-APIRequest'] = 'true';
    coreHeaders[HttpHeaders.acceptHeader] = ContentType.json.value;

    coreHeaders.forEach((key, value) {
      assert(
        !request.headers.containsKey(key) &&
            (_defaultHeaders == null || !_defaultHeaders!.containsKey(key)),
        'Overriding library core header ($key) is not allowed!',
      );
    });

    request.headers.addAll(coreHeaders);

    request.headers.putIfAbsent(
      HttpHeaders.contentTypeHeader,
      () => ContentType.json.value,
    );

    _defaultHeaders?.forEach((key, value) {
      //keep in mind that specific requests can pass request level headers
      //there is no guarantee that a sub client does not publish the option to add request specific headers
      //header priority: coreHeaders > requestHeaders > defaultHeaders
      request.headers.putIfAbsent(
        key,
        () => value,
      );
    });

    return _inner.send(request);
  }
}

/// RequestException class
class RequestException implements Exception {
  // ignore: public_member_api_docs
  RequestException(
    this.body,
    this.statusCode,
    this.url,
    this.method,
  );

  // ignore: public_member_api_docs
  String body;

  // ignore: public_member_api_docs
  int statusCode;

  // ignore: public_member_api_docs
  String url;

  // ignore: public_member_api_docs
  String method;
}

/// Organizes the requests
class Network {
  /// Create a network with the given client and base url
  Network(this._client);

  /// The http client
  final http.Client _client;

  /// send the request with given [method] and [url]
  Future<http.Response> send(
  String method,
  String url,
  List<int> expectedCodes, {
  Uint8List? data,
  Map<String, String>? headers,
  ProgressCallback? onProgress,
}) async {
  // ...existing code...


 
      final request = http.Request(method, Uri.parse(url));
      if (onProgress != null && data != null) {
        var sentBytes = 0;
        final totalBytes = data.length;
        final streamedData = Stream.fromIterable(data.map((byte) {
          sentBytes++;
          if (sentBytes % 1024 == 0) { // Update every KB
            onProgress(sentBytes, totalBytes);
          }
          return [byte];
        }));
        
        request.bodyBytes = await streamedData.expand((e) => e).toList();
      } else {
        request.bodyBytes = data ?? Uint8List(0);
      };
      request.headers.addAll(headers ?? {});
      final response = await _client.send(request);
      if (!expectedCodes.contains(response.statusCode)) {
        final r = await http.Response.fromStream(response);
        throw RequestException(
          r.body,
          r.statusCode,
          url,
          method,
        );
      }
      return http.Response.fromStream(response);
   
    // // If no response is returned, throw an exception
    // throw Exception('The send method did not return a response or handle all cases.');
}
  // Future<http.Response> send(
  //   String method,
  //   String url,
  //   List<int> expectedCodes, {
  //   Uint8List? data,
  //   Map<String, String>? headers,
  //   void Function(int bytesSent, int totalBytes)? onProgress,
  // }) async {
  //   final request = http.Request(method, Uri.parse(url))
  //     ..followRedirects = false
  //     ..persistentConnection = true
  //     ..headers.addAll(headers ?? {});

  //   if (data != null) {
  //     final totalBytes = data.length;
  //     int bytesSent = 0;

  //     request.bodyBytes = data;

  //     if (onProgress != null) {
  //       final stream = Stream.fromIterable([data]).transform(
  //         StreamTransformer.fromHandlers(
  //           handleData: (chunk, sink) {
  //             bytesSent += chunk.length;
  //             onProgress(bytesSent, totalBytes);
  //             sink.add(chunk);
  //           },
  //         ),
  //       );
  //       // request.bodyStream = stream;
  //     }
  //   }

  //   final response = await _client.send(request);

  //   if (!expectedCodes.contains(response.statusCode)) {
  //     final r = await http.Response.fromStream(response);

  //     throw RequestException(
  //       r.body,
  //       r.statusCode,
  //       url,
  //       method,
  //     );
  //   }

  //   return http.Response.fromStream(response);
  // }
  // Future<http.Response> send(
  //   String method,
  //   String url,
  //   List<int> expectedCodes, {
  //   Uint8List? data,
  //   Map<String, String>? headers,
  //   void Function(int bytesSent, int totalBytes)? onProgress,
  // }) async {
  //   final request = http.Request(method, Uri.parse(url))
  //     ..followRedirects = false
  //     ..persistentConnection = true
  //     ..bodyBytes = data ?? Uint8List(0)
  //     ..headers.addAll(headers ?? {});

  //   if (onProgress != null && data != null) {
  //     final totalBytes = data.length;
  //     int bytesSent = 0;

  //     request.finalize().listen(
  //       (chunk) {
  //         bytesSent += chunk.length;
  //         onProgress(bytesSent, totalBytes);
  //       },
  //     );
  //   }

  //   final response = await _client.send(request);

  //   if (!expectedCodes.contains(response.statusCode)) {
  //     final r = await http.Response.fromStream(response);

  //     throw RequestException(
  //       r.body,
  //       r.statusCode,
  //       url,
  //       method,
  //     );
  //   }

  //   return http.Response.fromStream(response);
  // }

  /// send the request with given [method] and [url]
  Future<http.StreamedResponse> download(
    String method,
    String url,
    List<int> expectedCodes, {
    Uint8List? data,
    Map<String, String>? headers,
  }) async {
    final response = await _client.send(
      http.Request(method, Uri.parse(url))
        ..followRedirects = false
        ..persistentConnection = true
        ..bodyBytes = data ?? Uint8List(0)
        ..headers.addAll(headers ?? {}),
    );

    if (!expectedCodes.contains(response.statusCode)) {
      final r = await http.Response.fromStream(response);

      throw RequestException(
        r.body,
        r.statusCode,
        url,
        method,
      );
    }
    return response;
  }
}
