import 'package:lyric/auth/spotify-auth-client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

abstract class SpotifyAuthState { }

class NotInitialized extends SpotifyAuthState { }

class WithToken extends SpotifyAuthState { 
  final String token;

  WithToken({ this.token });
}

abstract class SpotifyAuthEvent { }

class RequestAuthorizationCode extends SpotifyAuthEvent {
  final bool force;

  RequestAuthorizationCode({ @required this.force });
}

class RequestAuthorizationToken extends SpotifyAuthEvent { }

class SpotifyAuthBloc extends Bloc<SpotifyAuthEvent, SpotifyAuthState> {
  final spotifyAuthClient = SpotifyAuthClient();

  @override
  SpotifyAuthState get initialState => NotInitialized();

  @override
  Stream<SpotifyAuthState> mapEventToState(SpotifyAuthEvent event) async* {
    final store = FlutterSecureStorage();
    String token = await store.read(key: 'spotify_token');
    
    if (event is RequestAuthorizationToken) {
      if (token == null) {
        token = await spotifyAuthClient.authenticate();
        await store.write(key: 'spotify_token', value: token);
      }
      yield WithToken(token: token);
    } else {
      yield NotInitialized();
    }
  }
}
