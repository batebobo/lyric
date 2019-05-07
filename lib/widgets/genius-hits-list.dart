import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyric/blocs/genius-hit-selection-bloc.dart';
import 'package:lyric/models/genius-hit.dart';

class GeniusHitsList extends StatelessWidget {
  final List<GeniusHit> hits;
  final GeniusHitSelectionBloc bloc;

  const GeniusHitsList({Key key, this.hits, this.bloc}) : super(key: key);

    @override
  Widget build(BuildContext parentContext) {
    return BlocBuilder(
      builder: (BuildContext context, SelectionState state) {
        GeniusHit selected =
            state.selected.isPresent ? state.selected.value : hits[0];
        if (!state.selected.isPresent) {
          bloc.dispatch(SelectHitEvent(selected));
        }
        final hitsMap = hits.asMap();
        return Scaffold(
          body: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: hits
                      .map((hit) => RadioListTile(
                            title: Text(hit.title),
                            groupValue: selected.title,
                            onChanged: (String value) {
                              final selectedHit = hits.firstWhere((search) => search.title == value);
                              bloc.dispatch(SelectHitEvent(selectedHit));
                            },
                            selected: hit.title == selected.title,
                            value: hit.title,
                          ))
                      .toList(),
                ),
              ),
              CupertinoButton(
                child: Text('Yep, that\'s the one'),
                onPressed: () => Navigator.of(parentContext).pop(state.selected.value),
              )
            ],
          ),
        );
      },
      bloc: bloc,
    );
  }

}
