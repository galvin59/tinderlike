import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinderlike/bloc/deckBloc.dart';
import 'package:tinderlike/bloc/deckState.dart';
import 'package:tinderlike/include/global.dart';
import 'bloc/deckEvent.dart';
import 'deckCard.dart';
import 'model/cardItem.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

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

  double xPosition, yPosition, rotation = 0;
  final double maxRotationOnEdgeOfScreen = 15;
  final double prcScreenToValidaiton = 1 / 3;
  double initialxPosition, initialyPosition, initialxDragPosition, initialyDragPosition;
  double cardWidth, cardHeight, cardRatio = 3 / 2;
  double screenWidth, screenHeight;

  Animation<double> rotationAnimation;
  AnimationController animationController;
  Animation<Offset> offsetAnimation;

  DeckBloc deckBloc = new DeckBloc(); 

  @override
  void initState() {
    super.initState();
    BlocSupervisor.delegate = SimpleBlocDelegate();
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
    deckBloc.listen((deckState) {
      if (deckState is DeckStateLoaded) {
        setState(() { });
      } else if (deckState is DeckStateCardRefused) {
        print("Card " + deckState.card.toString() + " refused");
        setState(() { });
      } else if (deckState is DeckStateCardAccepted) {
        print("Card " + deckState.card.toString() + " accepted");
        setState(() { });
      }
    });
    deckBloc.add(DeckEventAppStarted());
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
      globalDeckRepository.getDeck()[0].status = status;
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
    var deck = globalDeckRepository.getDeck();
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
    animationController.removeStatusListener(cardThrownAwayListener);
    deckBloc.add(DeckEventTopCardThrownAway());
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
    var deck = globalDeckRepository.getDeck();
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
