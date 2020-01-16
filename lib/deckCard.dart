import 'package:flutter/material.dart';

import 'model/cardItem.dart';

class DeckCard extends StatefulWidget {
  const DeckCard({
    Key key,
    @required this.cardWidth,
    @required this.cardHeight,
    @required this.card,
  }) : super(key: key);

  final double cardWidth;
  final double cardHeight;
  final CardItem card;

  @override
  _DeckCardState createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> {

  Color getBorderColor()
  {
    switch (widget.card.status) {
      case cardStatus.none:
        return Colors.black;
        break;
      case cardStatus.yes:
        return Colors.green;
        break;
      case cardStatus.no:
        return Colors.red;
        break;    
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
      image: NetworkImage(widget.card.pictureURL),
      fit: BoxFit.cover,
    ),
          color: Colors.white, borderRadius: BorderRadius.circular(10), border : Border.all(color : getBorderColor(), style: BorderStyle.solid, width: 4)),
        width: widget.cardWidth,
        height: widget.cardHeight,
        );
  }
}