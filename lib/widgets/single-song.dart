import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/widgets/song-screen.dart';

class SingleSong extends StatelessWidget {
  final Song _song;
  SingleSong(this._song);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_song.name),
        ),
        child: SongScreen(song: _song)
    );
  }
}