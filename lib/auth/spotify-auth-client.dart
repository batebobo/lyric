
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyAuthClient {
  String url = 'https://accounts.spotify.com/authorize';
  final String clientId = 'bf969c9e7b0541aa9beec04e0da1df48';
  final String redirectUrl = 'lyricCustomSchemeName://';

  final String clientSecret = 'd52ca4718e7048d58d4dc9a3a82c64ff';

  void _addParameters() {
    final scopes = Uri.encodeComponent('user-read-playback-state user-read-recently-played');
    url +=
        '?client_id=$clientId&response_type=code&redirect_uri=$redirectUrl&scope=$scopes';
  }

  Future<Null> _issueInitialRequest() async {
    _addParameters();
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<String> _issueTokenRequest(String receivedCode) async {
    final Map<String, String> requestBody = {
      'grant_type': 'authorization_code',
      'code': receivedCode,
      'redirect_uri': redirectUrl,
      'client_id': clientId,
      'client_secret': clientSecret
    };
    final headers = { 
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Response result = await http.post(
      'https://accounts.spotify.com/api/token',
      body: requestBody,
      headers: headers,
    );
    final body = json.decode(result.body);
    final token = body['access_token'];
    final refreshToken = body['refresh_token'];
    final storage = FlutterSecureStorage();
    await storage.write(key: 'spotify_refresh_token', value: refreshToken);
    return token;
  }

  Future<String> _refreshToken(String refreshToken) async {
    final body = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
    };

    final code = base64.encode(utf8.encode('$clientId:$clientSecret')).toString();

    final headers = {
      'Authorization': 'Basic $code'
    };
    final storage = FlutterSecureStorage();


    final response = await http.post('https://accounts.spotify.com/api/token', headers: headers, body: body);
    final responseBody = json.decode(response.body);
    if (response.statusCode == 400) {
      await storage.delete(key: 'spotify_refresh_token');
      return _completeFlow();
    }
    final newRefreshToken = responseBody['refresh_token'];
    if (newRefreshToken != null) {
      await storage.write(key: 'spotify_refresh_token', value: newRefreshToken);
    }
    final newToken = responseBody['access_token'];
    return newToken;
  }

  Future<String> _completeFlow() async {
    await _issueInitialRequest();
    final uri = await getUriLinksStream().first;
    final code = uri.queryParameters['code'];
    return _issueTokenRequest(code);
  }

  Future<String> authenticate() async {
    final storage = FlutterSecureStorage();
    final refToken = await storage.read(key: 'spotify_refresh_token');
    if (refToken == null) {
      await storage.delete(key: 'spotify_refresh_token');
      return _completeFlow();
    }

    return _refreshToken(refToken);
  }
}