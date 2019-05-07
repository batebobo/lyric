import 'package:bloc/bloc.dart';
import 'package:lyric/models/genius-hit.dart';
import 'package:optional/optional.dart';

class SelectionState {
  Optional<GeniusHit> selected;
}

class SelectHitEvent {
  final GeniusHit selected;

  SelectHitEvent(this.selected);
}

class GeniusHitSelectionBloc extends Bloc<SelectHitEvent, SelectionState> {
  @override
  SelectionState get initialState => 
    SelectionState()
    ..selected = Optional.empty();

  @override
  Stream<SelectionState> mapEventToState(SelectHitEvent event) async* {
    final newState = GeniusHit(
      title: event.selected.title, 
      imageUrl: event.selected.imageUrl,
      url: event.selected.url,
    );
    yield SelectionState()
      ..selected = Optional.of(newState);
  }

}

