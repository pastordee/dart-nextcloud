import 'package:nextcloud/src/metadata/client.dart';
import 'package:nextcloud/src/webdav/client.dart';

/// NextCloudClient class
class NextCloudClient {
  // ignore: public_member_api_docs
  NextCloudClient(
    this.host,
    this.username,
    this.password, {
    this.port,
  }) {
    _webDavClient = WebDavClient(
      host,
      username,
      password,
      port: port,
    );
    _metaDataClient = MetaDataClient(
      host,
      username,
      password,
      port: port,
    );
  }

  // ignore: public_member_api_docs
  final String host;

  // ignore: public_member_api_docs
  final int port;

  // ignore: public_member_api_docs
  final String username;

  // ignore: public_member_api_docs
  final String password;

  WebDavClient _webDavClient;
  MetaDataClient _metaDataClient;

  // ignore: public_member_api_docs
  WebDavClient get webDav => _webDavClient;

  // ignore: public_member_api_docs
  MetaDataClient get metaData => _metaDataClient;
}
