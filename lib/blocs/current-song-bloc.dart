import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:lyric/services/genius-song-client.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';

class RequestSongEvent { }

class CurrentSongBloc extends Bloc<RequestSongEvent, Optional<Song>> {
  @override
  Optional<Song> get initialState => Optional.empty();

  final GeniusSongClient geniusSongClient = GeniusSongClient();
  SpotifyUserClient spotifyClient;

  CurrentSongBloc({ @required SpotifyUserClient spotifyClient }) {
    this.spotifyClient = spotifyClient;
  }

  @override
  Stream<Optional<Song>> mapEventToState(RequestSongEvent event) async* {
    final song = await spotifyClient.getCurrentTrack();

    bool hasTheSongChanged = Optional.ofNullable(song) != currentState;

    if (hasTheSongChanged) {
      song.lyrics = await geniusSongClient.getSongLyrics(song);
    }
    yield Optional.ofNullable(song);
  }
}