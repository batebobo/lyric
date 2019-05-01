import 'package:lyric/models/song.dart';

class SongNameFormatter {
  final Song song;
  SongNameFormatter(this.song);

  String _ignore(String stuff) {
   return '.+?(?=((- | \\()\\s*\\d*\\s*$stuff\\s*\\d*))' ;
  }

  String ignoreMisleadingSuffixes() {
    final name = song.name;
    final matches = [
      RegExp(_ignore('live'), caseSensitive: false).stringMatch(name),
      RegExp(_ignore('acoustic'), caseSensitive: false).stringMatch(name),
      RegExp(_ignore('single'), caseSensitive: false).stringMatch(name),
      RegExp(_ignore('remastered'), caseSensitive: false).stringMatch(name)
    ];

    final nonEmptyMatches = matches.where((match) => match != null);

    if (nonEmptyMatches.isNotEmpty) {
      return nonEmptyMatches.first;
    }
    return name;
  }
}