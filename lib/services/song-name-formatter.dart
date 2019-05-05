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

  List<String> _removeAll(List<String> search, { String from }) {
    return search.map((item) => _remove(item, from: from)).toList();
  }

  String ignoreMisleadingSuffixes() {
    final name = song.name;
    final matches = _removeAll(['live', 'acoustic', 'single', 'remastered'], from: name);

    final nonEmptyMatches = matches.where((match) => match != null);

    if (nonEmptyMatches.isNotEmpty) {
      return nonEmptyMatches.first;
    }
    return name;
  }
}