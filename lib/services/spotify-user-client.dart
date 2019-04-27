import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:lyric/auth/spotify-auth-client.dart';
import 'package:lyric/models/song.dart';
import 'package:optional/optional.dart';

class SpotifyUserClient {
    Future<Song> getCurrentTrack(String token) async {
    Map<String,String> headers = { 'Authorization': 'Bearer $token' };
    String url = 'https://api.spotify.com/v1/me/player';
    Response response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      final authClient = SpotifyAuthClient();
      final newToken = await authClient.reauthenticate();
      if (newToken == null) {
        return null;
      }
      headers = { 'Authorization': 'Bearer $newToken' };
      response = await http.get(url, headers: headers);
    }
    var decodedBody = json.decode(response.body);
    var item = decodedBody['item'];
    final song = Song(name: item['name'], artist: item['artists'][0]['name'], albumCoverUrl: item['album']['images'][0]['url']);
    song.lyrics = Optional.empty();
    return song;
  }
}