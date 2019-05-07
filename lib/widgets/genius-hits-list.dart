import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyric/models/genius-hit.dart';

class GeniusHitsList extends StatelessWidget {
  final List<GeniusHit> hits;
  final String selectedUrl;

  const GeniusHitsList({Key key, this.hits, this.selectedUrl}) : super(key: key);

  Widget _listItem(GeniusHit hit, bool selected, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(hit),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.all(8.0),
             child: Center(child: 
              Text(hit.title, 
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
            children: hits
                .map((hit) =>
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: _listItem(hit, selectedUrl == hit.url, context)))
                .toList(),
          ),
        ));
  }
}
