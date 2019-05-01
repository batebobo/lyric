import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:lyric/auth/spotify-auth-client.dart';
import 'package:lyric/models/song.dart';
import 'package:optional/optional.dart';

class LastTracksResponse {
  List<Song> songs;
  Error error;

  LastTracksResponse({ this.songs, this.error });
}

class UnauthorizedError extends Error { }

class SpotifyUserClient {
  Song _getSongFromSpotifyResponse(Map<String, dynamic> item) {
    return Song(name: item['name'], artist: item['artists'][0]['name'], albumCoverUrl: item['album']['images'][0]['url']);
  }

  SpotifyUserClient({ String token }) {
    this.token = token;
  }

  String token;

  Future<Song> getCurrentTrack() async {
    Map<String,String> headers = { 'Authorization': 'Bearer $token' };
    String url = 'https://api.spotify.com/v1/me/player';
    Response response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      final authClient = SpotifyAuthClient();
      token = await authClient.authenticate();
      headers = { 'Authorization': 'Bearer $token' };
      response = await http.get(url, headers: headers);
    }
    var decodedBody = json.decode(response.body);
    var item = decodedBody['item'];
    final song = _getSongFromSpotifyResponse(item);
    song.lyrics = Optional.empty();
    return song;
  }

  Future<LastTracksResponse> getLastTracks(int count) async {
    final String url = 'https://api.spotify.com/v1/me/player/recently-played?limit=$count';
    Map<String, String> headers = { 'Authorization': 'Bearer $token' };
    Response response = await http.get(url, headers: headers);
    LastTracksResponse output = LastTracksResponse();
    final body = json.decode(response.body);
    if (body['error'] != null && body['error']['status'] == 401) {
      token = await SpotifyAuthClient().authenticate();
      headers['Authorization'] = 'Bearer $token';
      response = await http.get(url, headers: headers);
    } if (body['error'] != null && body['error']['status'] == 403) {
      output.error = UnauthorizedError();
      return output;
    }
    final List<dynamic> items = body['items'];
    output.songs = items.map((item) => _getSongFromSpotifyResponse(item['track'])).toList();
    return output;
  }
}