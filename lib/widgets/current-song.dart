import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/current-song-bloc.dart';
import 'package:lyric/models/song.dart';
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
            final name = song.value.name;
            final artist = song.value.artist;
            final lyrics = song.value.lyrics.isPresent
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 10, right: 10, bottom: 80),
                    child: Text(song.value.lyrics.value,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        textAlign: TextAlign.center),
                  )
                : Text('No lyrics',
                    style: TextStyle(color: Colors.black, fontSize: 28));

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
                  '$name',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$artist',
                  style: TextStyle(color: Colors.black, fontSize: 21),
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
  }
}
