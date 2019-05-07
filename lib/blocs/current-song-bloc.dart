import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:lyric/services/genius-lyrics-client.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';

class RequestSongEvent { }

class CurrentSongBloc extends Bloc<RequestSongEvent, Optional<Song>> {
  @override
  Optional<Song> get initialState => Optional.empty();

  final GeniusLyricsClient geniusSongClient = GeniusLyricsClient();
  SpotifyUserClient spotifyClient;

  CurrentSongBloc({ @required SpotifyUserClient spotifyClient }) {
    this.spotifyClient = spotifyClient;
  }

  @override
  Stream<Optional<Song>> mapEventToState(RequestSongEvent event) async* {
    final newSong = await spotifyClient.getCurrentTrack();
    yield Optional.ofNullable(newSong);
  }
}