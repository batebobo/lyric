import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/auth/spotify-auth-bloc.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/current-song-bloc.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Bloc<SpotifyAuthEvent, SpotifyAuthState> spotifyAuthBloc = SpotifyAuthBloc();
  Bloc<RequestSongEvent, Optional<Song>> currentSongBloc = CurrentSongBloc();

  StreamSubscription<void> songRequestsSubscription;

  final spotifyClient = SpotifyUserClient();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    songRequestsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(decoration: TextDecoration.none),
      child: CupertinoPageScaffold(
        child: BlocBuilder(
            bloc: spotifyAuthBloc,
            builder: (BuildContext context, SpotifyAuthState state) {
              if (state is NotInitialized) {
                spotifyAuthBloc.dispatch(RequestAuthorizationCode());
                return Text('Requesting auth code');
              } else if (state is WithAuthorizationCode) {
                spotifyAuthBloc.dispatch(RequestAuthorizationToken());
                return Text('Requesting auth token');
              }
              final token = (state as WithToken).token;

              songRequestsSubscription = Observable.just(
                      currentSongBloc.dispatch(RequestSongEvent(token)))
                  .mergeWith([
                Observable.periodic(const Duration(seconds: 10)).map((_) =>
                    Observable.just(
                        currentSongBloc.dispatch(RequestSongEvent(token))))
              ]).listen((_) {});

              return BlocBuilder(
                  bloc: currentSongBloc,
                  builder: (BuildContext context, Optional<Song> song) {
                    if (song.isPresent) {
                      final name = song.value.name;
                      final artist = song.value.artist;
                      final lyrics = song.value.lyrics.isPresent
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 10, right: 10),
                              child: Text(
                                song.value.lyrics.value,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Text('No lyrics',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 28));

                      return SingleChildScrollView(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Image.network(
                              song.value.albumCoverUrl,
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                            ),
                          ),
                          Text(
                            '$artist - $name',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 28),
                            textAlign: TextAlign.center,
                          ),
                          lyrics
                        ],
                      ));
                    }
                    return Center(
                      child: Text(
                        'No song',
                        style: TextStyle(color: Colors.black, fontSize: 28),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
