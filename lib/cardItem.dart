import 'dart:convert';

class CardItem {

  String _pictureURL;

  String get pictureURL => _pictureURL;

  set pictureURL(String pictureURL) {
    _pictureURL = pictureURL;
  }

  cardStatus status = cardStatus.none;
  
  CardItem();
  factory CardItem.fromJson(dynamic _json) {
     var parsedJson = jsonDecode(_json);
    return CardItem()
      ..pictureURL = ((parsedJson['urls'] as List).last as Map).values.first;
  }

}

enum cardStatus { 
   none, 
   yes, 
   no 
}