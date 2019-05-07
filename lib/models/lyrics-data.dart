import 'package:lyric/models/genius-hit.dart';

class LyricsData {
  final String lyrics;
  final List<GeniusHit> geniusHits;
  final String lyricsUrl;

  LyricsData({this.lyrics, this.geniusHits, this.lyricsUrl});
}
