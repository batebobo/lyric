import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/genius-lyrics-model.dart';
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

  Widget _lyrics() => widget.song.lyricsData.isPresent
      ? _lyricsWidget(widget.song.lyrics)
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

  Widget _picture() => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Image.network(
          widget.song.albumCoverUrl,
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
        ),
      );

  Widget _name() => Text(
        '${widget.song.name}',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
        textAlign: TextAlign.center,
      );

  Widget _artist() => Text(
        '${widget.song.artist}',
        style: TextStyle(color: Colors.black, fontSize: 21),
        textAlign: TextAlign.center,
      );

  Future<GeniusLyricsModel> _showWrongLyricsDialog(BuildContext parentContext) {
    if (!widget.song.lyricsData.isPresent) {
      return Future.value(null);
    }
    return showCupertinoDialog<GeniusLyricsModel>(builder: (BuildContext context) {
      return CupertinoPopupSurface(
        isSurfacePainted: true,
        child: GeniusLyricsModelsList(
            models: widget.song.lyricsData.value.geniusLyricsModels,
            selectedUrl: widget.song.lyricsData.value.lyricsUrl
        ));
      }, context: parentContext
    );
  }

  void _updateSongLyrics(GeniusLyricsModel lyricsModel) async {
    if (lyricsModel == null) {
      return;
    }
    final newLyrics = await geniusClient.getSongLyricsFromUrl(lyricsModel.url);
    final lyricsData = Optional.of(LyricsData(
      geniusLyricsModels: widget.song.lyricsData.value.geniusLyricsModels,
      lyrics: newLyrics.value,
      lyricsUrl: lyricsModel.url
    ));
    if (mounted) {
      widget.song.lyricsData = lyricsData;
      setState(() {
        lyricsFetch = Future.value(lyricsData);
      });
    }
  }

  Widget _wrongLyricsButton(BuildContext parentContext) => CupertinoButton(
    child: Text('Wrong lyrics?'),
    color: Colors.blue,
    onPressed: () => _showWrongLyricsDialog(parentContext)
      .then(_updateSongLyrics)
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _picture(),
        _name(),
        _artist(),
        _wrongLyricsButton(context),
        _lyrics(),
      ],
    ));
  }
}
