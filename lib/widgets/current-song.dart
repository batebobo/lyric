import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/current-song-bloc.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/genius-song-client.dart';
import 'package:lyric/widgets/song-screen.dart';
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';

class CurrentSong extends StatefulWidget {
  const CurrentSong({
    Key key,
    @required this.currentSongBloc,
  }) : super(key: key);

  final CurrentSongBloc currentSongBloc;

  @override
  _CurrentSongState createState() => _CurrentSongState();
}

class _CurrentSongState extends State<CurrentSong> {
  StreamSubscription<void> currentSongSubscription;

  StreamSubscription<void> repeat(void Function() event, {@required Duration interval}) {
    return Observable.just(event()).mergeWith([
      Observable.periodic(interval).map((_) {
        Observable.just(event());
      })
    ]).listen((_) {});
  }

  @override
  void initState() {
    print('creating current song state');
    currentSongSubscription = repeat(() {
      widget.currentSongBloc.dispatch(RequestSongEvent());
    }, interval: const Duration(seconds: 10));
    super.initState();
  }

  @override
  void dispose() {
    print('disposing current song state');
    currentSongSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: widget.currentSongBloc,
        builder: (BuildContext context, Optional<Song> song) {
          if (song.isPresent) {
            return SongScreen(song: song.value);
          }
          return Center(
            child: Text(
              'No song',
              style: TextStyle(color: Colors.black, fontSize: 28),
            ),
          );
        });
  }
}
