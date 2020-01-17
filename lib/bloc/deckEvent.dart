import 'package:equatable/equatable.dart';
import 'package:tinderlike/model/cardItem.dart';

abstract class DeckEvent extends Equatable {
  DeckEvent([List props = const []]) : super(props);
}

class DeckEventAppStarted extends DeckEvent {
  @override
  String toString() => 'DeckEventAppStarted';
}

class DeckEventCardsFinishedLoading extends DeckEvent {
  @override
  String toString() => 'DeckEventCardsFinishedLoading';
}

class DeckEventTopCardThrownAway extends DeckEvent {
  @override
  String toString() => 'DeckEventTopCardThrownAway';
}

class DeckEventAddCard extends DeckEvent {
  @override
  String toString() => 'DeckEventAddCard';
  final CardItem card;
  final int index;
  DeckEventAddCard({this.card, this.index});
}
