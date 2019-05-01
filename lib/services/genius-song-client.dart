import 'dart:convert';
import 'package:lyric/models/song.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:lyric/services/song-name-formatter.dart';
import 'package:optional/optional.dart';

class GeniusSongClient {
  final String _accessToken = '1SEb2FUswZQckU-AFer41vm1MHUWBWpNdKJMuf1bjydx0lMjLZPrfUEK0Llb5Pkl';

  Future<Optional<String>> getSongLyrics(Song song) async {
    final formatter = SongNameFormatter(song);
    final String artist = song.artist;
    String name = song.name.split('(').first;
    name = formatter.ignoreMisleadingSuffixes();
    final String url = 'https://api.genius.com/search?q=$artist-$name';
    final headers = { 'Authorization': 'Bearer $_accessToken' };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      return Optional.empty();
    }
    final body = json.decode(response.body);
    final List<dynamic> hits = body['response']['hits'];
    if (hits.length < 1) {
      return Optional.empty();
    }
    final String path = hits[0]['result']['path'];
    return parseHtml(path);
  }

  String getAllText(Element node) {
    return node.nodes.fold('', (String result, Node childNode) {
      return result + childNode.text;
    });
  }
  Future<Optional<String>> parseHtml(String path) async {
    final String url = 'https://genius.com$path';
    final response = await http.get(url);

    final Document html = parse(response.body);
    final List<Element> lyricsNodes = html.querySelectorAll('div.lyrics p');
    if (lyricsNodes.length == 0) {
      return Optional.empty();
    }
    final String text = getAllText(lyricsNodes.first);
    return Optional.of(text);
  }
}