import 'package:bloc/bloc.dart';
import 'package:tinderlike/include/global.dart';
import 'package:tinderlike/model/cardItem.dart';
import 'deckEvent.dart';
import 'deckState.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  @override
  DeckState get initialState => DeckStateLoading();

  @override
  Stream<DeckState> mapEventToState(DeckEvent event) async* {
    if (event is DeckEventAppStarted) {
      yield DeckStateLoading();
      try {
        await globalDeckRepository.fetchDeck();
        yield DeckStateLoaded();
      } catch(e) {
        yield DeckStateError();
      }
    } else if (event is DeckEventTopCardThrownAway) {
      var _card = globalDeckRepository.discardTopCard();
      if (_card.status == cardStatus.yes) {
        yield DeckStateCardAccepted(card: _card);
      } else if (_card.status == cardStatus.no) {
        yield DeckStateCardRefused(card : _card);
      } else {
        yield DeckStateError();
      }
    } else if (event is DeckEventAddCard) {
      globalDeckRepository.insertCard(event.card, event.index);
      yield DeckStateCardAdded();
    }

  }
}