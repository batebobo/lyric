import 'package:lyric/models/genius-hit.dart';
import 'package:optional/optional.dart';
import 'package:equatable/equatable.dart';

class Song extends Equatable {
  String name;
  String artist;
  String albumCoverUrl;
  Optional<String> lyrics = Optional.empty();
  Optional<List<GeniusHit>> geniusHits = Optional.empty();

  @override
  bool operator ==(Object other) => other is Song && name == other.name && artist == other.artist;

  Song({ this.name, this.artist, this.albumCoverUrl }) {
    lyrics = Optional.empty();
  }
}
