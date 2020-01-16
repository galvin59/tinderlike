import 'package:equatable/equatable.dart';

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
