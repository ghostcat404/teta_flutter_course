import 'dart:io';
import 'package:blackjack/cards.dart';


abstract class Person {
  Hand hand;

  Person(this.hand);

  String decide();

  String get stringHand;

  void putCardIntoHand(Card card) => hand.putCard(card);
  
  int get getScore => hand.getScore;
}


class Dealer extends Person {
  int isMyTurn = 0;

  Dealer(super.hand);

  // TODO: create dealer logic
  @override
  String decide() {
    if (hand.getScore <= 16) {
      return '1';
    }
    else {
      return '2';
    }
  }

  @override
  String get stringHand {
    if (
      isMyTurn == 1
      || hand.cards[0].cardValue.weight == 10
      || hand.cards[0].cardValue == CardValue.ace
    ) {
      return hand.toString();
    }
    else {
      return '${hand.cards[0].toString()} -';
    }
  }
}


class Gamer extends Person {

  Gamer(super.hand);

  @override
  String decide() {
    String? decision = stdin.readLineSync()?.trim();
    if (decision != '1' || decision != '2' || decision == null) {
      decision = '2';
    }
    return decision;
  }
  @override
  String get stringHand => hand.toString();
}
