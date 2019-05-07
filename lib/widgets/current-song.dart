import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/current-song-bloc.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/widgets/loading.dart';
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

  StreamSubscription<void> _repeat(void Function() event, {@required Duration interval}) {
    return Observable.just(event()).mergeWith([
      Observable.periodic(interval).map((_) {
        Observable.just(event());
      })
    ]).listen((_) {});
  }

  @override
  void initState() {
    currentSongSubscription = _repeat(() {
      widget.currentSongBloc.dispatch(RequestSongEvent());
    }, interval: const Duration(seconds: 10));
    super.initState();
  }

  @override
  void dispose() {
    currentSongSubscription.cancel();
    super.dispose();
  }

  final Widget loading = Center(child: Loading(radius: 40));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: widget.currentSongBloc,
        builder: (BuildContext context, Optional<Song> song) =>
          song.isPresent ?
            SongScreen(song: song.value) :
            loading
    );
  }
}
