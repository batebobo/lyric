import 'package:lyric/models/genius-lyrics-model.dart';

class LyricsData {
  final String lyrics;
  final List<GeniusLyricsModel> geniusLyricsModels;
  final String lyricsUrl;

  LyricsData({this.lyrics, this.geniusLyricsModels, this.lyricsUrl});
}
