import 'dart:convert';
import 'package:lyric/models/genius-lyrics-model.dart';
import 'package:lyric/models/lyrics-data.dart';
import 'package:lyric/models/song.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:lyric/services/song-name-formatter.dart';
import 'package:optional/optional.dart';

class GeniusLyricsClient {
  final String _accessToken = '1SEb2FUswZQckU-AFer41vm1MHUWBWpNdKJMuf1bjydx0lMjLZPrfUEK0Llb5Pkl';

  Future<Optional<LyricsData>> getSongLyrics(Song song) async {
    final formatter = SongNameFormatter(song);
    final String artist = song.artist;
    String name = song.name.split('(').first;
    name = formatter.ignoreMisleadingSuffixes();
    final String url = 'https://api.genius.com/search?q=$artist-$name';
    final headers = { 'Authorization': 'Bearer $_accessToken' };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 401) {
      return song.lyricsData;
    }
    final body = json.decode(response.body);
    final List<dynamic> hits = body['response']['hits'];
    if (hits.length < 1) {
      return song.lyricsData;
    }
    final String path = GeniusLyricsModel.fromJson(hits[0]).url;
    final geniusLyricsModels = Optional.of(hits.map((json) => GeniusLyricsModel.fromJson(json)).toList());
    final lyrics = await getSongLyricsFromUrl(path);
    if (!lyrics.isPresent || !geniusLyricsModels.isPresent) {
      return song.lyricsData;
    }
    return Optional.of(LyricsData(
      geniusLyricsModels: geniusLyricsModels.value,
      lyrics: lyrics.value,
      lyricsUrl: geniusLyricsModels.value.first.url
    ));
  }

  String _getAllText(Element node) {
    return node.nodes.fold('', (String result, Node childNode) {
      return result + childNode.text;
    });
  }
  Future<Optional<String>> getSongLyricsFromUrl(String path) async {
    final String url = 'https://genius.com$path';
    final response = await http.get(url);

    final Document html = parse(response.body);
    final List<Element> lyricsNodes = html.querySelectorAll('div.lyrics p');
    if (lyricsNodes.length == 0) {
      return Optional.empty();
    }
    final String text = _getAllText(lyricsNodes.first);
    return Optional.of(text);
  }
}