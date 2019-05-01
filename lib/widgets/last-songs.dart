import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/last-songs-bloc.dart';
import 'package:lyric/blocs/spotify-auth-bloc.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/widgets/single-song.dart';

class LastSongsList extends StatelessWidget {
  final LastSongsBloc lastSongsBloc;

  const LastSongsList({Key key, this.lastSongsBloc })
      : super(key: key);

  List<Widget> _songsWidgets(List<Song> songs, BuildContext context) {
    return songs
        .map((song) => ListTile(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => SingleSong(song)
            )),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                song.albumCoverUrl,
              ),
            ),
            title: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(song.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            subtitle: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(song.artist,
                    style: TextStyle(color: Colors.black, fontSize: 20)),
              ),
            )))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    lastSongsBloc.dispatch(RequestLastSongsEvent(count: 10));
    return BlocBuilder(
      bloc: lastSongsBloc,
      builder: (BuildContext context, LastSongsState state) {
        if (state is Some) {
          return Scaffold(body: ListView(children: _songsWidgets(state.songs, context)));
        } else if (state is None) {
          return CupertinoActivityIndicator(animating: true, radius: 60);
        } else if (state is Unauthorized) {
          return Center(child: Text('Authorizing'));
        }
      },
    );
  }
}
