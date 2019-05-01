import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/current-song-bloc.dart';
import 'package:lyric/blocs/last-songs-bloc.dart';
import 'package:lyric/blocs/spotify-auth-bloc.dart';
import 'package:lyric/services/spotify-user-client.dart';
import 'package:lyric/widgets/current-song.dart';
import 'package:lyric/widgets/last-songs.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({Key key, this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpotifyUserClient userClient;

  @override
  void initState() {
    userClient = SpotifyUserClient(token: widget.token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<CurrentSongBloc>(
            bloc: CurrentSongBloc(spotifyClient: userClient)),
        BlocProvider<LastSongsBloc>(
            bloc: LastSongsBloc(BlocProvider.of<SpotifyAuthBloc>(context), spotifyClient: userClient))
      ],
      child: DefaultTextStyle(
          style: TextStyle(decoration: TextDecoration.none),
          child: CupertinoPageScaffold(
              child: CupertinoTabScaffold(
            tabBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return CurrentSong(
                    currentSongBloc: BlocProvider.of<CurrentSongBloc>(context));
              } else if (index == 1) {
                return LastSongsList(
                    lastSongsBloc: BlocProvider.of<LastSongsBloc>(context));
              }
              return Center(
                  child: Text("Not implemented",
                      style: TextStyle(color: Colors.black)));
            },
            tabBar: CupertinoTabBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.music_note), title: Text('Current')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_music), title: Text('Last 10')),
              ],
            ),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
          ))),
    );
  }
}
