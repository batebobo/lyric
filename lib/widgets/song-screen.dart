import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/genius-hit.dart';
import 'package:lyric/models/lyrics-data.dart';
import 'package:lyric/models/song.dart';
import 'package:lyric/services/genius-lyrics-client.dart';
import 'package:lyric/widgets/genius-hits-list.dart';
import 'package:lyric/widgets/loading.dart';
import 'package:optional/optional.dart';

class SongScreen extends StatefulWidget {
  final Song song;

  SongScreen({Key key, this.song}) : super(key: key);

  @override
  _SongScreenState createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  Future<Optional<LyricsData>> lyricsFetch;
  final geniusClient = GeniusLyricsClient();
  static const loading = Loading(radius: 40);

  @override
  initState() {
    lyricsFetch = geniusClient.getSongLyrics(widget.song);
    super.initState();
  }

  @override
  void didUpdateWidget(SongScreen oldWidget) {
    if (oldWidget.song != widget.song) {
      lyricsFetch = geniusClient.getSongLyrics(widget.song);
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _lyricsWidget(String text) => Padding(
        padding:
            const EdgeInsets.only(top: 30.0, left: 10, right: 10, bottom: 80),
        child: Text(text,
            style: TextStyle(color: Colors.black, fontSize: 18),
            textAlign: TextAlign.center),
      );

  Widget _lyrics(Song song) => song.lyricsData.isPresent
      ? _lyricsWidget(song.lyrics)
      : FutureBuilder(
          future: lyricsFetch,
          builder: (BuildContext context, AsyncSnapshot<Optional<LyricsData>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data.isPresent) {
                widget.song.lyricsData = snapshot.data;
                return _lyricsWidget(snapshot.data.value.lyrics);
              }
              return loading;
          },
        );

  Widget _picture(Song song) => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Image.network(
          song.albumCoverUrl,
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
        ),
      );

  Widget _name(String name) => Text(
        '$name',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
        textAlign: TextAlign.center,
      );

  Widget _artist(String artist) => Text(
        '$artist',
        style: TextStyle(color: Colors.black, fontSize: 21),
        textAlign: TextAlign.center,
      );

  Widget _wrongLyricsButton(Song song, BuildContext parentContext) => CupertinoButton(
    child: Text('Wrong lyrics?'),
    color: Colors.blue,
    onPressed: () => showCupertinoDialog<GeniusHit>(builder: (BuildContext context) {
      return CupertinoPopupSurface(
        isSurfacePainted: true,
        child: GeniusHitsList(
            hits: song.lyricsData.value.geniusHits,
            selectedUrl: song.lyricsData.value.lyricsUrl
      ));
    }, context: parentContext
    ).then((GeniusHit hit) async {
      final newLyrics = await geniusClient.parseHtml(hit.url);
      final lyricsData = Optional.of(LyricsData(
        geniusHits: song.lyricsData.value.geniusHits,
        lyrics: newLyrics.value,
        lyricsUrl: hit.url
      ));
      if (mounted) {
        widget.song.lyricsData = lyricsData;
        setState(() {
          lyricsFetch = Future.value(lyricsData);
        });
      }
    })
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _picture(widget.song),
        _name(widget.song.name),
        _artist(widget.song.artist),
        _wrongLyricsButton(widget.song, context),
        _lyrics(widget.song),
      ],
    ));
  }
}
