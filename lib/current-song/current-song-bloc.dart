import 'package:bloc/bloc.dart';
import 'package:lyric/services/genius-song-client.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:optional/optional.dart';

class RequestSongEvent { 
  final String token;

  RequestSongEvent(this.token);
}

class CurrentSongBloc extends Bloc<RequestSongEvent, Optional<Song>> {
  @override
  Optional<Song> get initialState => Optional.empty();

  final GeniusSongClient geniusSongClient = GeniusSongClient();

  @override
  Stream<Optional<Song>> mapEventToState(RequestSongEvent event) async* {
    final client = SpotifyUserClient();
    final start = DateTime.now();
    final song = await client.getCurrentTrack(event.token);
    final end = DateTime.now();
    final duration = end.difference(start).inMilliseconds;
    print('Request to get the current song took $duration ms');

    bool hasTheSongChanged = Optional.ofNullable(song) != currentState;

    if (hasTheSongChanged) {
      print('Getting lyrics');
      song.lyrics = await geniusSongClient.getSongLyrics(song);
    }
    yield Optional.ofNullable(song);
  }
}