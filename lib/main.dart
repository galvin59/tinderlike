import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tinderlike/cardItem.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import 'deckCard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double xPosition;
  double yPosition;
  double rotation = 0;

  final double maxRotationOnEdgeOfScreen = 15;
  final double prcScreenToValidaiton = 1 / 3;

  double initialxPosition;
  double initialyPosition;
  double initialxDragPosition;
  double initialyDragPosition;

  double cardWidth;
  double cardHeight;
  double cardRatio = 3 / 2;

  double screenWidth;
  double screenHeight;

  Animation<double> rotationAnimation;
  AnimationController animationController;
  Animation<Offset> offsetAnimation;

  List<CardItem> deck;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      cardWidth = 0.66 * screenWidth;
      cardHeight = cardWidth * cardRatio;
      initialxPosition = (screenWidth - cardWidth) / 2;
      initialyPosition = (screenHeight - cardHeight) / 2;
      xPosition = initialxPosition;
      yPosition = initialyPosition;
      animationController = AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
    });
    getCards();
  }

  void updateWhenDrag(DragUpdateDetails details) {
    print("updateWhenDrag > Start");
    setState(() {
      xPosition += details.delta.dx;
      yPosition += details.delta.dy;
      print("new x : " +
          xPosition.toString() +
          " , new y : " +
          yPosition.toString());
      final double distanceFromCenterX = (xPosition - initialxPosition);
      var status;
      if (distanceFromCenterX.abs() < (screenWidth * prcScreenToValidaiton)) {
        status = cardStatus.none;
      } else if (distanceFromCenterX > 0) {
        status = cardStatus.yes;
      } else {
        status = cardStatus.no;
      }
      deck[0].status = status;
      rotation = (maxRotationOnEdgeOfScreen *
              distanceFromCenterX /
              (screenWidth / 2)) /
          360 *
          (screenHeight / 2 - initialyDragPosition).sign;
      rotationAnimation = new AlwaysStoppedAnimation(rotation);
    });
    print("updateWhenDrag > End");
  }

  void dragEnd(DragEndDetails details) {
    animationController.reset();
    print("dragEnd > Start");
    setState(() {
      if (deck[0].status == cardStatus.none) {
        offsetAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset((initialxPosition - xPosition) / cardWidth,
              (initialyPosition - yPosition) / cardHeight),
        ).animate(animationController);
        rotationAnimation =
            Tween<double>(begin: rotation, end: 0).animate(animationController);
      } else {
        offsetAnimation = Tween<Offset>(
                begin: Offset.zero,
                end: Offset((deck[0].status == cardStatus.no) ? -1 : 1, 0))
            .animate(animationController);
        rotationAnimation =
            Tween<double>(begin: rotation, end: 0).animate(animationController);
      }
    });
    animationController.forward();
    if (deck[0].status != cardStatus.none) {
      animationController.addStatusListener(cardThrownAwayListener);
    }
    print("dragEnd > End");
  }

  void cardThrownAwayListener(AnimationStatus status) {
    xPosition = initialxPosition;
    yPosition = initialyPosition;
    offsetAnimation = null;
    setState(() {
      deck.removeAt(0);
    });
    animationController.removeStatusListener(cardThrownAwayListener);
  }

  void dragStart(DragStartDetails details) {
    initialxDragPosition = details.globalPosition.dx;
    initialyDragPosition = details.globalPosition.dy;
    setState(() {
      xPosition = initialxPosition;
      yPosition = initialyPosition;
      rotationAnimation = AlwaysStoppedAnimation(0);
      offsetAnimation = AlwaysStoppedAnimation(Offset.zero);
    });
  }

  getCards() async {
    final String APIKey = "#getAPIkeyFromhttps://generated.photos";
    final response =
        await http.get('https://api.generated.photos/api/v1/faces?api_key=' + APIKey);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      deck = List<CardItem>();
      for (int i = 0; i < json["faces"].length; i++) {
        var card = CardItem.fromJson(jsonEncode(json["faces"][i]));
        deck.add(card);
      }
      setState(() {});
    }
  }

  Widget getCard(CardItem _cardItem) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: RotationTransition(
          turns: (rotationAnimation == null)
              ? AlwaysStoppedAnimation(0)
              : rotationAnimation,
          child: SlideTransition(
            position: (offsetAnimation == null)
                ? AlwaysStoppedAnimation(Offset.zero)
                : offsetAnimation,
            child: GestureDetector(
                child: DeckCard(
                    card: _cardItem,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight),
                onPanEnd: (details) {
                  dragEnd(details);
                },
                onPanStart: (details) {
                  dragStart(details);
                },
                onPanUpdate: (details) {
                  updateWhenDrag(details);
                }),
          )),
    );
  }

  Widget getUnderneathCard(CardItem _cardItem) {
    return Positioned(
        top: initialyPosition,
        left: initialxPosition,
        child: DeckCard(
            card: _cardItem, cardWidth: cardWidth, cardHeight: cardHeight));
  }

  Widget getStack() {
    if (deck == null) {
      return Center(child: CircularProgressIndicator());
    }
    Stack _stack = new Stack(
      children: <Widget>[
        (deck.length>1)?getUnderneathCard(deck[1]):Container(), 
        (deck.length>0)?getCard(deck[0]):Container()],
    );
    return _stack;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getStack());
  }
}
