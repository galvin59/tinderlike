import 'package:equatable/equatable.dart';
import 'package:tinderlike/model/cardItem.dart';

abstract class DeckState extends Equatable {
  @override
  List<Object> get props => [];
}

class DeckStateLoading extends DeckState {}

class DeckStateLoaded extends DeckState {}

class DeckStateCardAccepted extends DeckState {
  final CardItem card;
  DeckStateCardAccepted({this.card});
}

class DeckStateCardRefused extends DeckState {
  final CardItem card;
  DeckStateCardRefused({this.card});
}

class DeckStateCardAdded extends DeckState {}

class DeckStateError extends DeckState{}
