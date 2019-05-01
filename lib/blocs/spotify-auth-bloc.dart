import 'package:lyric/auth/spotify-auth-client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:meta/meta.dart';
import 'package:uni_links/uni_links.dart';

abstract class SpotifyAuthState { }

class NotInitialized extends SpotifyAuthState { }

class WithAuthorizationCode extends SpotifyAuthState {
  final String authorizationCode;

  WithAuthorizationCode({ this.authorizationCode });
}

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
    if (event is RequestAuthorizationCode) {
      if (token != null && !event.force) {
        yield WithToken(token: token);
      } 
      else {
        await spotifyAuthClient.issueInitialRequest();
        final uri = await getUriLinksStream().first;
        final code = uri.queryParameters['code'];
        await store.write(key: 'spotify_auth_code', value: code);
        yield WithAuthorizationCode(authorizationCode: uri.queryParameters['code']);
      }
    }
    else if (event is RequestAuthorizationToken) {
      if (token == null) {
        final code = await store.read(key: 'spotify_auth_code');
        if (code == null) {
          yield NotInitialized();
        } else {
          token = await spotifyAuthClient.issueTokenRequest(code);
        }
      }
      yield WithToken(token: token);
    } else {
      yield NotInitialized();
    }
  }
}
