import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/genius-song-client.dart';
import 'package:optional/optional.dart';

class SingleSong extends StatefulWidget {
  final Song _song;
  Future<Optional<String>> lyricsFetch;
  SingleSong(this._song) {
    lyricsFetch = GeniusSongClient().getSongLyrics(_song);
  }

  @override
  _SingleSongState createState() => _SingleSongState();
}

class _SingleSongState extends State<SingleSong> {
  @override
  Widget build(BuildContext context) {
    final name = widget._song.name;
    final artist = widget._song.artist;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget._song.name),
        ),
        child: SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).padding,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Image.network(
                  widget._song.albumCoverUrl,
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
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
                FutureBuilder(
                  future: widget.lyricsFetch,
                  builder: (BuildContext context,
                      AsyncSnapshot<Optional<String>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        return Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, left: 10, right: 10, bottom: 80),
                            child: Text(snapshot.data.value,
                                style:
                                    TextStyle(color: Colors.black, fontSize: 18),
                                textAlign: TextAlign.center));
                        break;
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return Center(
                            child: CupertinoActivityIndicator(
                                animating: true, radius: 40));
                      default:
                        return Center(child: Text("Error"));
                    }
                  },
                ),
              ]),
            )));
  }
}
