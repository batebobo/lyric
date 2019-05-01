import 'package:bloc/bloc.dart';
import 'package:lyric/blocs/spotify-auth-bloc.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:meta/meta.dart';

class RequestLastSongsEvent {
  final int count;

  RequestLastSongsEvent({ this.count });
}

abstract class LastSongsState { }

class None extends LastSongsState { }

class Some extends LastSongsState {
  final List<Song> songs;

  Some(this.songs);
}

class Unauthorized extends LastSongsState { }

class LastSongsBloc extends Bloc<RequestLastSongsEvent, LastSongsState> {
  final SpotifyAuthBloc spotifyAuthBloc;

  @override
  LastSongsState get initialState => None();

  SpotifyUserClient _userClient;

  LastSongsBloc(this.spotifyAuthBloc, { @required SpotifyUserClient spotifyClient }) {
    _userClient = spotifyClient;
  }

  @override
  Stream<LastSongsState> mapEventToState(RequestLastSongsEvent event) async* {
    final response = await _userClient.getLastTracks(event.count);
    if (response.error != null && response.error is UnauthorizedError) {
      spotifyAuthBloc.dispatch(RequestAuthorizationCode(force: true));
      yield Unauthorized();
    } else {
      yield Some(response.songs);
    }
  }
  
}