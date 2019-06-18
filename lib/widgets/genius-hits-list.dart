import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/genius-lyrics-model.dart';

class GeniusLyricsModelsList extends StatelessWidget {
  final List<GeniusLyricsModel> models;
  final String selectedUrl;

  const GeniusLyricsModelsList({Key key, this.models, this.selectedUrl}) : super(key: key);

  Widget _listItem(GeniusLyricsModel lyricsModel, bool selected, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(lyricsModel),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.all(8.0),
             child: Center(child: 
              Text(lyricsModel.title, 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 18, color: selected ? Colors.green : Colors.black))),
          ))
    );
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: models
                .map((lyricsModel) =>
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: _listItem(lyricsModel, selectedUrl == lyricsModel.url, context)))
                .toList(),
          ),
        ));
  }
}
