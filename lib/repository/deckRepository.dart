import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tinderlike/model/cardItem.dart';

class DeckRepository {

  List<CardItem> _deck;

  List<CardItem> getDeck() {
    return _deck;
  }

  Future fetchDeck() async {
    final String APIKey = "VeqefLfiWAVbChOwp_7nfg";
    final response = await http.get('https://api.generated.photos/api/v1/faces?api_key=' + APIKey);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      _deck = List<CardItem>();
      for (int i = 0; i < json["faces"].length; i++) {
        var card = CardItem.fromJson(jsonEncode(json["faces"][i]));
        _deck.add(card);
      }
    }
    return _deck;
  }

  CardItem discardTopCard()
  {
    var result = _deck[0];
    _deck.removeAt(0);
    return result;
  }

  void insertCard(CardItem card, int index) {
    _deck.insert(index, card);
  }

}