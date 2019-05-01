import 'package:lyric/models/song.dart';

class SongNameFormatter {
  final Song song;
  SongNameFormatter(this.song);

  String _ignore(String stuff) {
   return '.+?(?=((- | \\()\\s*\\d*\\s*$stuff\\s*\\d*))' ;
  }

  String _remove(String search, { String from }) {
    return RegExp(_ignore(search), caseSensitive: false).stringMatch(from);
  }

  String ignoreMisleadingSuffixes() {
    final name = song.name;
    final matches = [
      _remove('live', from: name),
      _remove('acoustic', from: name),
      _remove('single', from: name),
      _remove('remastered', from: name),
    ];

    final nonEmptyMatches = matches.where((match) => match != null);

    if (nonEmptyMatches.isNotEmpty) {
      return nonEmptyMatches.first;
    }
    return name;
  }
}