import 'dart:convert';

import 'package:http/http.dart' as http;

class DemoApi {
  static const _base = String.fromEnvironment('AUCTE_API_URL');
  static const _token = String.fromEnvironment('AUCTE_DEMO_TOKEN');

  static bool get configured => _base.isNotEmpty && _token.isNotEmpty;

  static Uri _url(String path) =>
      Uri.parse('${_base.replaceFirst(RegExp(r'/+$'), '')}$path');

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Accept': 'application/fhir+json',
  };

  static Future<List<dynamic>> getTerms() async {
    final response = await http
        .get(_url('/api/codings'), headers: _headers)
        .timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) {
      throw StateError('Demo terminology service is unavailable');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  }

  static Future<void> upload(String bundleJson) async {
    final response = await http
        .post(
          _url('/api/encounters'),
          headers: {..._headers, 'Content-Type': 'application/fhir+json'},
          body: utf8.encode(bundleJson),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 201) return;
    final outcome = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    final issues = outcome['issue'] as List?;
    final message = issues?.firstOrNull?['diagnostics'];
    throw FormatException(message?.toString() ?? 'Upload failed');
  }
}
