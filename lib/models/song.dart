import 'package:lyric/models/genius-hit.dart';
import 'package:lyric/models/lyrics-data.dart';
import 'package:optional/optional.dart';
import 'package:equatable/equatable.dart';

class Song extends Equatable {
  String name;
  String artist;
  String albumCoverUrl;
  Optional<LyricsData> lyricsData = Optional.empty();

  get lyrics => lyricsData.value.lyrics;

  @override
  bool operator ==(Object other) => other is Song && name == other.name && artist == other.artist;

  Song({ this.name, this.artist, this.albumCoverUrl }) {
    lyricsData = Optional.empty();
  }
}
